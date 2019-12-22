# TODO documentation
class nebula {
  include 'archive'

  archive { '/opt/nebula-cert.tgz':
    ensure       => present,
    extract      => true,
    extract_path => '/usr/local/bin/',
    source       => 'https://github.com/slackhq/nebula/releases/download/v1.0.0/nebula-linux-amd64.tar.gz',
    creates      => '/usr/local/bin/nebula-cert',
    cleanup      => true,
  }
}

# TODO documentation
class nebula::ca (String $ca_name, Array $hosts = []) inherits nebula {
  file { '/etc/nebula-ca':
    ensure => 'directory',
    group  => 'puppet',
    owner  => 'puppet',
    mode   => '0660'
  }

  exec { 'nebula-cert-ca':
    command => "/usr/local/bin/nebula-cert ca -name \"${ca_name}\"",
    cwd     => '/etc/nebula-ca',
    creates => '/etc/nebula-ca/ca.crt',
    require => [Archive['/opt/nebula-cert.tgz'], File['/etc/nebula-ca']],
  }

  file { '/etc/nebula-ca/ca.crt':
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0640',
    require => Exec['nebula-cert-ca'],
  }

  file { '/etc/nebula-ca/ca.key':
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0640',
    require => Exec['nebula-cert-ca']
  }

  # create_resources(nebula_host_ip, {})

  # Clients definition
  $hosts.each |Hash $host| {
    $host_name = $host['host_name']
    $address = $host['address']

    $command = [
      '/usr/local/bin/nebula-cert',
      'sign',
      '-ca-crt', '/etc/nebula-ca/ca.crt', '-ca-key', '/etc/nebula-ca/ca.key',
      '-out-crt', "/etc/nebula-ca/${host_name}.crt",  '-out-key', "/etc/nebula-ca/${host_name}.key",
      '-name', 'name', '-ip', $address
    ]

    exec { "ca_${host_name}":
      command => join($command, ' '),
      cwd     => '/etc/nebula-ca',
      creates => ["/etc/nebula-ca/${host_name}.crt", "/etc/nebula-ca/${host_name}.key"],
    }

    file { "host_ca_${host_name}":
      path    => "/etc/nebula-ca/${host_name}.crt",
      owner   => 'puppet',
      group   => 'puppet',
      mode    => '0640',
      require => Exec["ca_${host_name}"]
    }

    file { "host_key_${host_name}":
      path    => "/etc/nebula-ca/${host_name}.key",
      owner   => 'puppet',
      group   => 'puppet',
      mode    => '0640',
      require => Exec["ca_${host_name}"]
    }

    @@nebula_host { $host_name:
      private_ip => $address,
      tag        => 'nebula_host',
    }
  }
}

# TODO documentation
class nebula::host (String $host_name) inherits nebula {
  file { '/etc/nebula':
    ensure  => 'directory',
    require => [Archive['/opt/nebula-cert.tgz']],
  }

  file { 'ca':
    ensure => present,
    owner  => 'root',
    path   => "/etc/nebula/ca.crt",
    source => "puppet:///nebula_certs/ca.crt"
  }

  file { 'host_ca':
    ensure => present,
    owner  => 'root',
    path   => "/etc/nebula/${host_name}.crt",
    source => "puppet:///nebula_certs/${host_name}.crt"
  }

  file { 'host_key':
    ensure => present,
    owner  => 'root',
    path   => "/etc/nebula/${host_name}.key",
    source => "puppet:///nebula_certs/${host_name}.key"
  }

  $nhosts = puppetdb_query('resources { exported = true and type = "Nebula_host" }')

  file { '/etc/nebula/config.yml':
    ensure  => present,
    content => template('nebula/config.erb'),
  }
}
