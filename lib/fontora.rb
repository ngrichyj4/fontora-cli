
require File.expand_path('../dependencies', File.dirname(__FILE__))
require 'open-uri'
require 'ostruct'
require 'json'
require 'digest/sha2'
require 'securerandom'
require 'colorize'
require 'celluloid/current'
require 'awesome_print'
require 'mechanize'
require 'dotenv/load'
require 'public_suffix'
require 'crass'
require 'open_uri_redirections'
require 'active_support/all'
require 'fontora/logger'
require 'fontora/version'
require 'fontora/utils/methods'
require 'fontora/utils/tasker'
require 'fontora/spider/spider'
require 'fontora/site/crawler'
require 'fontora/site/css'
require 'fontora/site/parser'
require 'fontora/site/font'

Fontora::Logger.stdout = false
Thread.abort_on_exception=true
module Fontora
end
