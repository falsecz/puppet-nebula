include nebula

node 'agent1' {
  include nebula

  class { 'nebula::host':
    host_name => 'fuka',
    address   => '192.168.33.5/24',
  }
}

node 'puppet' {
  class { 'nebula::ca':
    ca_name => 's9y',
  }

  # problemy - tohle musim zakomentovat dokud neni vytvoreni ca
  class { 'nebula::host':
    host_name => 'svetylko',
    address   => '192.168.33.1/24',
  }
}
