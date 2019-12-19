# TODO documentation
class nebula (Optional[Array[Hash[String[1], Any]]] $mapa = []) {
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
class nebula::ca (String $ca_name) inherits nebula {
  file { '/etc/nebula-ca':
    ensure => 'directory',
    group  => 'puppet',
    mode   => '0660'
  }

  exec { 'nebula-cert-ca':
    command => "/usr/local/bin/nebula-cert ca -name \"${ca_name}\"",
    cwd     => '/etc/nebula-ca',
    creates => '/etc/nebula-ca/ca.crt',
    require => [Archive['/opt/nebula-cert.tgz'], File['/etc/nebula-ca']],
  }

  file { '/etc/nebula-ca/ca.crt':
    owner   => 'root',
    group   => 'puppet',
    mode    => '0640',
    require => Exec['nebula-cert-ca']
  }

  file { '/etc/nebula-ca/ca.key':
    owner   => 'root',
    group   => 'puppet',
    mode    => '0640',
    require => Exec['nebula-cert-ca']
  }
}

# TODO documentation
class nebula::host (String $host_name, String $address) inherits nebula {
  file { '/etc/nebula':
    ensure  => 'directory',
    require => [Archive['/opt/nebula-cert.tgz']],
  }

  create_resources(nebula_host, {})

  @@nebula_host { $host_name:
    private_ip => $address,
    tag        => 'nebula_host',
  }

  $nhosts = puppetdb_query('resources { exported = true and type = "Nebula_host" }')

  $opts = {
    'name' => $host_name,
    'address' => $address,
  }

  # PRO BENÍKA <3
  # Háže ejjoj
  # Error: Failed to apply catalog: Function nebula_hostcert not defined despite being loaded!
  $ca = Deferred('nebula_hostcert', ['ca', $opts])
  # $crt = Deferred('nebula_hostcert', ['crt', $opts])
  # $key = Deferred('nebula_hostcert', ['key', $opts])

  notify { 'example':
    message => $ca
  }

  # file { '/etc/nebula/ca.crt':
  #   ensure  => present,
  #   content => $ca,
  #   require => File['/etc/nebula'],
  # }

  # file { '/etc/nebula/nebula.crt':
  #   ensure  => present,
  #   content => $crt,
  #   require => File['/etc/nebula'],
  # }

  # file { '/etc/nebula/nebula.key':
  #   ensure  => present,
  #   content => $key,
  #   require => File['/etc/nebula'],
  # }

  file { '/etc/nebula/config.yml':
    ensure  => present,
    content => template('nebula/config.erb'),
  }
}
