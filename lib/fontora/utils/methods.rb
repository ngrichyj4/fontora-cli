module Fontora
 module Utils
  module Methods
   BLACK_LIST = [ :@content, :@parsed_content, :@stylesheets, :@stylesheet ] # Don't show in irb console too large
   def root_domain link
    host = URI.parse(link.to_s).host
    PublicSuffix.domain(host)
   end

   def inspect
    public_vars = self.instance_variables.reject { |var|
      BLACK_LIST.include? var
    }.map { |var|
      "#{var}=\"#{instance_variable_get(var)}\""
    }.join(" ")

    "<##{self.class}:#{self.object_id.to_s(8)} #{public_vars}>"
    end

   module_function :root_domain
  end
 end
end