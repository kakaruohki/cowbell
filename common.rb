require 'optparse'
require 'pry'
require 'sinatra'
require 'line/bot'
require 'active_record'
require 'logger'
require 'selenium-webdriver'
require 'nokogiri'

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
  host: 'cowbell2.cxzk5qiw2yej.us-east-2.rds.amazonaws.com',
  username: 'root',
  password: 'okkr1154',
  database: 'cowbell',
)

class Items < ActiveRecord::Base;
end

class Users < ActiveRecord::Base;
end
