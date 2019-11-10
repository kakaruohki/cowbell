require 'sinatra'
require 'active_record'
require 'logger'
require_relative '../get_affiliate'

helpers do
  def html(text)
    Rack::Utils.escape_html(text)
  end
end

ActiveRecord::Base.default_timezone = :local
ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection(
  adapter: 'mysql2',
  host: 'localhost',
  username: 'root',
  password: '',
  database: 'cowbell',
)

class Items < ActiveRecord::Base;
end


get '/get_affiliate' do
  erb :get_affiliate
end

post '/result' do
  @item_code = params[:item_code]
  affiliate_url = Share.new.get_affiliate_url(@item_code)
  detail_hash = Share.new.parse_detail(@item_code)
  Items.create(site_name: detail_hash["site_name"], item_name: detail_hash["item_name"], reference_price: detail_hash["reference_price"], normal_price: detail_hash["normal_price"], sale_price: detail_hash["sale_price"], affiliate_url: affiliate_url, item_code: @item_code)
  binding.pry
  erb :result
end
