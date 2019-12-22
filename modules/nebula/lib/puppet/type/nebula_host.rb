Puppet::Type.newtype(:nebula_host) do
    ensurable
    @doc = "kek"

    newparam(:name) do
        isnamevar
        desc "The name of the nebula host"
    end

    newproperty(:private_ip) do
        desc "ip"
    end
  end