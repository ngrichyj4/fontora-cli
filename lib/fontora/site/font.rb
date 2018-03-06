# => Accepts a instance of a crawler and gets all fonts on the site
module Fontora
 module Site
  class Font
   include Celluloid
   include Fontora::Utils::Methods
   attr_accessor :id, :source, :root_uri, :fonts
   
   def initialize 
   end

   def load! stylesheet, options
    @id = options[:id]
    @source   = options[:source]
    @root_uri = root_domain @source
    @host_id  = options[:host_id]
    @host     = options[:host]
    @stylesheet = stylesheet! stylesheet
    @fonts = future.font_finder.value
    self.dup
   end

   #
   # => Get stylesheet text if future object
   #
   def stylesheet! style
    return style.value if style.respond_to?(:value)
    style
   end

   #
   # => Look through CSS parser for @font-face links
   #
   def font_finder
    at_rules = @stylesheet.find_all { |rule| rule[:node] == :at_rule && rule[:name] == 'font-face' }
    return [] unless at_rules.present?
    functions = at_rules.map{|at_rule| at_rule[:block].find_all {|rule| rule[:node] == :function && rule[:name] == 'url' } }.flatten
    block_uris = at_rules.map{|at_rule| at_rule[:block].find_all {|rule| rule[:node] == :url } }.flatten
    urls = block_uris.map{|node| absolute_uri node[:value]  }
    urls.concat functions.map {|func| func[:value].map {|node| absolute_uri node[:value] }}.flatten
    # urls.flatten.uniq.map {|font| future.get_font_info font }
    urls.flatten.uniq.map {|font| crawler.parser.future.get_font_info font, @host, @source, @root_uri }
   end

   def crawler
    Crawler.nodes[@host_id]
   end

   def absolute_uri path
    @source ? URI.join(@source, path) : path
   end

   def get_source font_uri
    return nil unless @source
    @root_uri == root_domain(font_uri) ? 'internal' : 'external'
   end

  end
 end
end
