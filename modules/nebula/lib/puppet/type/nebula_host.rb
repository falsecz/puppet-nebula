# frozen_string_literal: true

Puppet::Type.newtype(:nebula_host) do
    @doc = 'A type representing a Docker volume'
    ensurable
  
    newparam(:public_ip) do
      isnamevar
      desc 'The name of the volume'
    end
  
    newproperty(:private_ip) do
      desc 'The volume driver used by the volume'
    end
  
    # newproperty(:options) do
    #   desc 'Additional options for the volume driver'
    # end
  
    # newproperty(:mountpoint) do
    #   desc 'The location that the volume is mounted to'
    #   validate do |value|
    #     raise(Puppet::ParseError, "#{value} is read-only and is only available via puppet resource.")
    #   end
    # end
  end