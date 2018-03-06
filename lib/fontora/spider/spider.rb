# => Run crawler on multple sites
module Fontora
 module Site
  module Spider
   def scrape urls, options={}
    default_options options
    crawler = Crawler.pool(size: options[:crawler])
    urls.map {|site| crawler.future.start! site, options }
   end

   def default_options options
    options.merge! crawler: options[:crawler] || 5 
    options.merge! css:     CSS.pool(size: options[:css] || 10)
    options.merge! parser:  Parser.pool(size: options[:parser] || 10)
    options.merge! font:    Font.pool(size: options[:font] || 10)
    options.merge! font_info: options[:font_info].nil? ? true : options[:font_info]
   end

   module_function :scrape, :default_options
  end
 end
end
