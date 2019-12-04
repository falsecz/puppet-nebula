# # asdsd

# # Puppet::Functions.create_function(:nebula_hostcert') do
# #   dispatch :up do
# #     param 'String', :some_string
# #   end

# #   def up(some_string)
# #     some_string.upcase
# #   end
# # end


# module Puppet::Parser::Functions
#   newfunction(:nebula_hostcert, type: :rvalue) do |args|
#     java_args = args[0] || {}
#     args = ''
#     java_args.each { |k, v| args += "#{k}#{v} " }
#     "\"#{args.chomp(' ')}\""
#   end
# end

require 'socket'

Puppet::Parser::Functions::newfunction(:nebula_hostcert, :arity => -2, :type => :rvalue,
  :doc => "Calls an external command on the Puppet master and returns
  the results of the command. Any arguments are passed to the external command as
  arguments. If the generator does not exit with return code of 0,
  the generator is considered to have failed and a parse error is
  thrown. Generators can only have file separators, alphanumerics, dashes,
  and periods in them. This function will attempt to protect you from
  malicious generator calls (e.g., those with '..' in them), but it can
  never be entirely safe. No subshell is used to execute
  generators, so all shell metacharacters are passed directly to
  the generator, and all metacharacters are returned by the function.
  Consider cleaning white space from any string generated.") do |args|

    #TRANSLATORS "fully qualified" refers to a fully qualified file system path
    
    type = args[0]
    opts = args[1]

    name = opts['name']
    
    
    Puppet.info("parameter 'parametro' has value '#{1}'")
    args = [
        "/usr/local/bin/nebula-cert",
        "sign",
        '-ca-crt', "/etc/nebula-ca/ca.crt", "-ca-key", "/etc/nebula-ca/ca.key", 
        "-out-crt", "/etc/nebula-ca/#{name}.crt",  "-out-key", "/etc/nebula-ca/#{name}.key", 
        "-name", 'name', "-ip", opts['address']
    ]
    if(type == 'key')
      file = "/etc/nebula-ca/#{name}.key"
    elsif(type == 'crt') 
      file = "/etc/nebula-ca/#{name}.crt"
    elsif(type == 'ca') 
      file = "/etc/nebula-ca/ca.crt"
    else
      raise Puppet::ParseError, _("neznamej type #{type}")
    end
    
    ## TODO hlidat konflikty ip

    ## TODO co pregenerovani ?
    ## vygeneruj
    Puppet::Util::Execution.execute(args).to_str unless File.exist?(file)


    return File.read(file)
    # raise Puppet::ParseError, _(Socket.gethostname)
  
    # raise Puppet::ParseError, _("Generators must be fully qualified") unless Puppet::Util.absolute_path?(args[0])

    
    # if Puppet::Util::Platform.windows?
    #   valid = args[0] =~ /^[a-z]:(?:[\/\\][-.~\w]+)+$/i
    # else
    #   valid = args[0] =~ /^[-\/\w.+]+$/
    # end

    # unless valid
    #   raise Puppet::ParseError, _("Generators can only contain alphanumerics, file separators, and dashes")
    # end

    # if args[0] =~ /\.\./
    #   raise Puppet::ParseError, _("Can not use generators with '..' in them.")
    # end

    # begin
      
    # rescue Puppet::ExecutionFailure => detail
    #   raise Puppet::ParseError, _("Failed to execute generator %{generator}: %{detail}") % { generator: args[0], detail: detail }, detail.backtrace
    # end
end