Puppet::Type.newtype(:nebula_host) do
    ensurable
    @doc = "kek"

    newparam(:name) do
        isnamevar
        desc "The name of the nebula host"
    end

    newproperty(:private_ip) do
        desc "private_ip"
    end

    newproperty(:public_ip) do
        desc "public_ip"
    end
  end