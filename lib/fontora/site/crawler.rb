module Fontora
 module Site
  class Crawler
   include Celluloid
   include Fontora::Utils::Methods
   include Fontora::Utils::Tasker
   attr_accessor :uri, :root_uri, :content, :stylesheets, :scripts, :meta, 
    :icons, :browser, :parser, :css, :font, :font_info
   # trap_exit :actor_died

   # def actor_died(actor, reason)
   #  Logger.error "Oh no! #{actor.inspect} has died because of a #{reason.class}"
   # end
   
   # -------------------
   #    CLASS METHODS
   # ------------------
   class << self
    attr_accessor :nodes
    def init!
     @nodes ||= {}
    end
   end

   def initialize 
    Crawler.init!
    @id = get_id
   end

   def start! uri, options
    @uri         = nomalize_uri uri
    @root_uri    = root_domain @uri
    @content     = future.get_content
    @stylesheets = []
    setup_browser
    @css       = options[:css]
    @parser    = options[:parser]
    @font      = options[:font]
    @font_info = options[:font_info]

    task :get_stylesheets, :get_meta, :get_scripts, :get_icons
    wait_until_completion!  

    # Should return a duplicate of self, because when using Celloloid::Pool. 
    # instance an be assigned to another object, and it can destroy/change its value
    self.dup   
   end

   def get_id
    uuid = SecureRandom.uuid
    Crawler.nodes[uuid] = self
    uuid
   end

   def setup_browser
    @browser = Mechanize.new
    @browser.verify_mode = OpenSSL::SSL::VERIFY_NONE
    @browser.user_agent_alias = 'Windows Chrome'
    @browser.history.max_size = 0 
    @browser.follow_meta_refresh = false
    @browser.keep_alive = false
   end

   def nomalize_uri uri
    return uri if uri.starts_with?('http://') || uri.starts_with?('https://')
    'http://' + uri
   end

   #
   # => Get content from page
   #
   def get_content
    Logger.info 'Get site: ' + @uri.to_s
    @browser.get uri
   rescue => e
    Logger.error 'Cannot open: ' + @uri.to_s + ' | Reason: ' + e.message
    nil
   end

   #
   # => List on fonts found in stylesheets
   #
   def fonts
    stylesheets.map(&:fonts).flatten.compact.reject(&:empty?)
   end 

   #
   # =>  Get linked stylesheets and body
   #
   def get_stylesheets
    page = content.value
    return unless page
    page.css('style').each {|style| stylesheets << @css.load!(:body, host_id: @id, 
     content: style.text, host_uri: uri, fonts: @font_info) }
    page.css("link[rel=stylesheet]").each do |link| 
     if link.attributes['href'] && link.attributes['href'].value
      absolute_uri = URI.join(uri, link.attributes['href'].value)
      stylesheets << @css.load!(:uri, uri: absolute_uri, host_id: @id, host_uri: uri, fonts: @font_info)
     end
    end
   end

   #
   # =>  Get all linked scripts
   #
   def get_scripts
    page =  content.value
    return unless page
    @scripts = page.search('script').map(&:text).reject(&:empty?)
    @scripts.concat page.search("script").map { |script| script.attributes['src'].value rescue nil }.compact.uniq
   end

   #
   # => Get all meta tags
   #
   def get_meta
    page =  content.value
    return unless page
    @meta = page.search("meta").map do |meta|
     meta.attributes.each_with_object({}) do |el, hash|
      hash[el.first] = el.last.to_s
     end
    end
    
    @meta.concat [{ 'name' => 'title', 'value' => page.title }]
   end

   #
   # => Get all site favicons
   #
   def get_icons
    page =  content.value
    return unless page
    @icons = page.css("head link[rel*='icon']").map do |favicon| 
     Addressable::URI.join(@uri, favicon['href']).to_s rescue favicon['href']  
    end
   end

   # Return all style only for root domain
   def get_domain_stylesheets
    stylesheets.reject{|style| style.source==:uri && style.root_uri != root_uri  }
   end

   # Return all styles that was imported from another domain
   def get_external_stylesheets
    stylesheets.select {|style| style.root_uri != root_uri }
   end


  end
 end
end
