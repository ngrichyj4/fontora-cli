module Fontora
 module Site
  class CSS
   include Celluloid
   include Fontora::Utils::Methods
   include Fontora::Utils::Tasker
   
   attr_accessor :id, :source, :uri, :root_uri, :content, :parsed_content, :font
   def initialize 
   end

   def load! source, params
    @uri       = params[:uri]
    @host_id   = params[:host_id]
    @host_uri  = params[:host_uri]
    @root_uri  = root_domain @uri
    @source    = source
    @content   = OpenStruct.new value: params[:content] if source == :body
    @content   = future.get_resource if source == :uri
    @parsed_content = future.parse_content
    task :set_id, :find_and_follow_imports
    task :get_fonts if params[:fonts]
    wait_until_completion!

    self.dup
   end

   #
   # => Parse CSS file as AST
   #
   def parse_content
    return unless content?
    Crass.parse(@content.value, preserve_comments: false) 
   end 

   #
   # => Check parsed css and follow import uri
   #
   def find_and_follow_imports
    return unless parsed_content?
    stylesheet = @parsed_content.value
    at_rules = stylesheet.find_all { |rule| rule[:node] == :at_rule && rule[:name] == 'import' }
    import_uris = at_rules.map{|at_rule| at_rule[:tokens].find_all {|rule| rule[:node] == :string } }.flatten
    urls = import_uris.map{|node| absolute_uri node[:value]  }
    urls.uniq.each do |uri| 
     stylesheets = crawler.css.load!(:uri, uri: uri, host_id: @host_id, host_uri: @host_uri, fonts: crawler.font_info)
     crawler.stylesheets << stylesheets
    end
   end

   def absolute_uri path
    @uri ? URI.join(@uri, path) : path
   end

   #
   # => Scrape all fonts in stylesheets
   #
   def get_fonts
    return unless parsed_content?
    @font = crawler.font.load! parsed_content, source: uri, id: id , host: @host_uri, host_id: @host_id
   end

   #
   # => Get all fonts from current stylesheet
   #
   def fonts
    @font.fonts.map(&:value)
   rescue => e
    nil
   end

   def crawler
    Crawler.nodes[@host_id]
   end

   def internal_fonts 
    crawler.stylesheets.map {|style| style.font if style.font.root_uri ==  crawler.root_uri }.compact
   end

   def external_fonts
    crawler.stylesheets.map {|style| style.font if style.font.root_uri !=  crawler.root_uri }.compact
   end

   def uri?
    source == :uri
   end

   def body?
    source == :body
   end

   def content?
    !@content.value.nil?
   end

   def parsed_content?
    return unless content?
    !@parsed_content.value.nil?
   end

   #
   # => Generate id from stylesheet content
   #
   def set_id
    return unless content?
    sha = Digest::SHA256.new
    sha.update(@content.value)
    @id = sha.hexdigest
   end

   #
   # => Load CSS from file
   #
   def get_resource
    data = open(uri, allow_redirections: :safe).read
    Logger.info 'Got resource: ' + uri.to_s
    data
   rescue => e 
    Logger.error 'Failed to get: ' + @uri.to_s + ' | Reason: ' + e.message
    nil
   end

  end
 end
end