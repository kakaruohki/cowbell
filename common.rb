require 'rubygems'
require 'bundler'
require 'nokogiri'
require 'socket'
require 'pp'
require 'json'
require 'uri'
require 'active_record'
require 'active_support'
require 'active_support/core_ext'
require 'open-uri'
#require 'open_uri_redirections'
require 'mechanize'
require 'selenium-webdriver'
require 'date'
require 'time'
#require 'aws-sdk'
require 'optparse'
require 'pry'
require 'sinatra'
require 'line/bot'

ActiveRecord::Base.default_timezone = :local
ActiveRecord::Base.logger = Logger.new(STDOUT)
#ActiveRecord::Base.establish_connection(
#  adapter: 'mysql2',
#  host: 'localhost',
#  username: 'root',
#  password: '',
#  database: 'cowbell',
#)

ActiveRecord::Base.establish_connection(
  adapter: 'mysql2',
  host: 'localhost',
  username: 'root',
  password: '',
  database: 'cowbell',
)

class Items < ActiveRecord::Base;
end

class Users < ActiveRecord::Base;
end
