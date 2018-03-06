require 'fontora'

# Scrape fonts from following sites
urls = ["example1.com", "example2.com", "example2.com"]
scraper = Fontora::Site::Spider.scrape urls, font_info: true

# Site
scraper[0].value.icons #> Get all favicons found on page
scraper[0].value.stylesheets #> Get all stylesheets found on page
scraper[0].value.scripts #> Get all scripts found on page
scraper[0].value.fonts #> Get fonts found on all stylesheets for page 

# Stylesheet
stylesheet = scraper[0].value.stylesheets.first
stylesheet.content #> View CSS file
stylesheet.parsed_content #> View AST of CSS file.
stylesheet.font.fonts #> View fonts found stylesheet