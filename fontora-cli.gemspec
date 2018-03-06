lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fontora/version'

Gem::Specification.new do |s|
  s.name        = 'fontora-cli'
  s.version     = Fontora::VERSION
  s.date        = '2018-02-23'
  s.summary     = "Fontora CLI"
  s.description = "This library helps you scrape font information from multiple websites concurrently."
  s.platform    = Gem::Platform::RUBY
  s.authors     = [ "Richard Aberefa" ]
  s.email       = 'ngrichyj4@gmail.com'
  s.license     = "MIT"
  s.files       = Dir['Gemfile', 'LICENSE.md', 'README.md', 'lib/**/*', 'nodejs/**/*', 'tmp/**/*', 'dependencies.rb']
  s.homepage    = 'https://github.com/ngrichyj4/fontora-cli'
  s.add_dependency 'json', '~> 1.8.3', '>= 1.8.3'
  s.add_dependency 'activesupport', '~> 5.0.2', '>= 5.0.2'
  s.add_dependency 'colorize', '~> 0.8.1', '>= 0.8.1'
  s.add_dependency 'awesome_print', '~> 1.8.0', '>= 1.8.0'
  s.add_dependency 'celluloid', '~> 0.17.3'
  s.add_dependency 'mechanize', '~> 2.7.5', '>= 2.7.5'
  s.add_dependency 'dotenv', '~> 2.2.1', '>= 2.2.1'
  s.add_dependency 'public_suffix', '~> 3.0.1', '>= 3.0.1'
  s.add_dependency 'crass', '~> 1.0.3', '>= 1.0.3'
  s.add_dependency 'open_uri_redirections', '~> 0.2.1'
  s.add_dependency 'addressable', '~> 2.5.2', '>= 2.5.2'
end