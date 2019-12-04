include nebula
  
node 'agent1' {
  include nebula
  
  class { 'nebula::host':
    meno    => 'fuka',
    address => '192.168.33.5/24',
  }
} 


node 'puppet' {
  class { 'nebula::ca':
    ca_name => 's9y',
  }
  
  ## problemy - tohle musim zakomentovat dokud neni vytvoreni ca
  class { 'nebula::host':
    meno => 'svetylko',
    address => '192.168.33.1/24',
    
  }

} 
