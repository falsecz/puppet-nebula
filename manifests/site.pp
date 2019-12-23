include nebula

node 'agent1' {
  class { 'nebula::host':
    host_name => 'fuka',
  }
}

node 'agent2' {
  class { 'nebula::host':
    host_name => 'zidan',
  }
}

node 'puppet' {
  service { 'puppetserver':
    ensure => 'running'
  }

  puppet_authorization::rule { 'auth_certs':
    match_request_path => '^/puppet/v3/file_(content|metadata)s?/nebula_certs',
    match_request_type => 'regex',
    allow              => '*',
    sort_order         => 300,
    path               => '/etc/puppetlabs/puppetserver/conf.d/auth.conf',
    notify             => Service['puppetserver'],
  }

  file { '/etc/puppetlabs/puppet/fileserver.conf':
    ensure  => 'present',
    owner   => 'puppet',
    group   => 'puppet',
    content => "[nebula_certs]\n  path /etc/nebula-ca\n  allow *",
    notify  => Service['puppetserver'],
  }

  class { 'nebula::ca':
    ca_name => 's9y',
    hosts   => [
      { host_name => 'fuka', address => '192.168.33.5/24', public_ip => 'agent1.test' },
      { host_name => 'svetylko', address => '192.168.33.1/24', public_ip => 'puppet.test' },
      { host_name => 'zidan', address => '192.168.33.7/24', public_ip => 'agent2.test' },
    ],
    require => [Puppet_authorization::Rule['auth_certs'], File['/etc/puppetlabs/puppet/fileserver.conf']]
  }

  class { 'nebula::host':
    host_name => 'svetylko',
    require   => Class['nebula::ca']
  }
}
