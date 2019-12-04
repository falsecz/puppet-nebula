class nebula(
  Optional[Array[Hash[String[1], Any]]] $mapa                    = [],
) {
include 'archive'

  

archive { '/opt/nebula-cert.tgz':
  ensure        => present,
  extract       => true,
  extract_path  => '/usr/local/bin/',
  source        => 'https://github.com/slackhq/nebula/releases/download/v1.0.0/nebula-linux-amd64.tar.gz',
  # checksum      => '2ca09f0b36ca7d71b762e14ea2ff09d5eac57558',
  # checksum_type => 'sha1',
  creates       => '/usr/local/bin/nebula-cert',
  # group => 'puppet',
  cleanup       => true,
}
}

class nebula::ca (String   $ca_name) inherits nebula {

  file { '/etc/nebula-ca':
        ensure => 'directory',
        group => 'puppet',
        mode => '0660'
    }


  exec { "nebula-cert-ca":
    command => "/usr/local/bin/nebula-cert ca -name \"${ca_name}\"",
    cwd     => '/etc/nebula-ca',
    creates => '/etc/nebula-ca/ca.crt',
    # path    => ['/usr/bin', '/usr/sbin',],
    require => [Archive['/opt/nebula-cert.tgz'], File['/etc/nebula-ca']],
  }

  file { "/etc/nebula-ca/ca.crt":
      owner => "root",
      group => "puppet",
      mode => '0640',  
      require => Exec['nebula-cert-ca']
  }
  file { "/etc/nebula-ca/ca.key":
        owner => "root",
        group => "puppet",
        mode => '0640',  
        require => Exec['nebula-cert-ca']
    }

}

class nebula::host(
  String $meno,
  String $address
  ) inherits nebula{


  file { '/etc/nebula':
    ensure => 'directory',
    require => [Archive['/opt/nebula-cert.tgz']],
  }

create_resources (nebula_host, {})


# $last_node_query = 'nodes{order by report_timestamp desc limit 1}'
# $latest_node = puppetdb_query($last_node_query)[0]['certname']
# Notify {"hello PQL":
#     message => "My last report was from $latest_node.",
# }

  @@nebula_host {$meno:
    private_ip => $address,
    tag => 'nebula_host',
  }

$nhosts = puppetdb_query('resources { exported = true and type = "Nebula_host" }')


  # @@file { "/tmp/${meno}":
  #   content => "[${address}]\n other munin stuff here", 
  #   tag => "munin",
  # }
  # File <<| tag == 'munin' |>>

# file { "/etc/bacula_clients":
#     ensure => directory,
#     purge => true,
#     recurse => true,
#     force => true,
#   }

#   Concat::Fragment <<| tag == 'nebula_host' |>>

#   $majaky =  <<| |>> 
# Concat::Fragment <<| tag == "bacula-storage-dir-${bacula_director}" |>>
  $opts = {
    'name' => $meno,
    'address' => $address,
  }
  file { "/etc/nebula/ca.crt":
      ensure => present,
      content => nebula_hostcert('ca', $opts),
      require => File['/etc/nebula'],
  }

  file { "/etc/nebula/nebula.crt":
      ensure => present,
      content => nebula_hostcert('crt', $opts),
      require => File['/etc/nebula'],
  }
  file { "/etc/nebula/nebula.key":
      ensure => present,
      content => nebula_hostcert('key', $opts),
      require => File['/etc/nebula'],
  }

  file { "/etc/nebula/config.yml":
      ensure => present,
      content => template('nebula/config.erb'),
  }


}
  