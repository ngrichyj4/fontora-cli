# Fontora CLI

This library helps you scrape font information from multiple uri concurrently.

## Installation

You need to clone the git repo and build the gem locally:

```bash
$ git clone https://github.com/ngrichyj4/fontora-cli && cd fontora-cli
$ gem build fontora-cli.gemspec
```

And then execute:

    $ gem install fontora-cli-version.gem # use appropriate version

### Node.js
*NOTE: To get additional font info using the font parser you also need to install node.js. Installable via `brew install node` on OS X.*

## Usage

See [examples](examples).

A simple scraper to get font information.

```ruby
require 'fontora'
Fontora::Logger.stdout = true #> Verbose: output logs to stdout
urls = ["example1.com", "example2.com", "example2.com"]
scraper = Fontora::Site::Spider.scrape urls, font_info: true  # font_info: true requires Node.js
```

This snippet will crawl the sites and return an array of `Celluloid::Future` objects. Call `value` on each item to view the results.

```ruby
results = scraper.map(&:value)
fonts = results.first.fonts
```

### Scaling
You can scale the number of workers you want to run concurrently for each job. 

```ruby
Fontora::Site::Crawler.pool #> handles scraping multiple sites concurrently.
Fontora::Site::CSS.pool     #> handles css files.
Fontora::Site::Font.pool    #> handles font files.
Fontora::Site::Parser.pool  #> handles nodejs parser for font files.
```
You can initialize the scraper with custom pool sizes like so: 

```ruby 
scraper = Fontora::Site::Spider.scrape urls, crawler: 25, font: 50, css: 50, parser: 100, font_info: true
```

### Font info
Here's an example of what a font info will look like.

```ruby
{:host=>"http://culturatolteca.com",
  :stylesheet_uri=>
   #<URI::HTTP http://culturatolteca.com/wp-content/themes/mts_schema/css/font-awesome.min.css?ver=4.9.4>,
  :font_uri=>
   #<URI::HTTP http://culturatolteca.com/wp-content/themes/mts_schema/fonts/fontawesome-webfont.woff>,
  :info=>
   {:parser=>
     {:"en-US"=>
       {:copyright=>"SIL Open Font License 1.1",
        :fontFamily=>"FontAwesome",
        :fontSubfamily=>"Regular",
        :uniqueSubfamily=>"FONTLAB:OTFEXPORT",
        :fullName=>"FontAwesome Regular",
        :version=>"Version 4.0.2 2013",
        :postscriptName=>"FontAwesome",
        :trademark=>
         "Please refer to the Copyright section for the font trademark attribution notices.",
        :manufacturer=>"Fort Awesome",
        :designer=>"Dave Gandy",
        :vendorURL=>"http://fontawesome.io"}}},
  :source=>"internal"},
{:host=>"http://culturatolteca.com",
  :stylesheet_uri=>
   #<URI::HTTP http://fonts.googleapis.com/css?family=Roboto+Slab:normal|Raleway:500|Raleway:700|Roboto+Slab:300&subset=latin>,
  :font_uri=>
   #<URI::HTTP http://fonts.gstatic.com/s/robotoslab/v7/BngMUXZYTXPIvIBgJJSb6ufN5qA.ttf>,
  :info=>
   {:parser=>
     {:"en-US"=>
       {:copyright=>"Font data copyright Google 2013",
        :fontFamily=>"Roboto Slab",
        :fontSubfamily=>"Regular",
        :uniqueSubfamily=>"Google:Roboto Slab:2013",
        :fullName=>"Roboto Slab Regular",
        :version=>
         "Version 1.100263; 2013; ttfautohint (v0.94.20-1c74) -l 8 -r 12 -G 200 -x 14 -w \"\" -W",
        :postscriptName=>"RobotoSlab-Regular",
        :licenseURL=>"http://www.apache.org/licenses/LICENSE-2.0"}}},
  :source=>"external"},
```

## Contributing

1. Fork it ( https://github.com/ngrichyj4/fontora-cli/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request