require 'pry'
require 'sinatra'
require 'line/bot'
require 'active_record'
require 'logger'
require 'json'

helpers do
  def html(text)
    Rack::Utils.escape_html(text)
  end
end

#正常か確認
post '/' do
   "Hello world!"
end

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_id     = CHANNEL_ID
    config.channel_secret = CHANNEL_SECRET
    config.channel_token  = CHANNEL_TOKEN
  }
end

require_relative '../qoo10/qoo10_parser'
require_relative '../rakuten/rakuten_parser'

#商品情報の際における通知
def reply(user_id, status)
  uri = URI.parse("https://api.line.me/v2/bot/message/push")
  request = Net::HTTP::Post.new(uri)
  request.content_type = "application/json"
  request["Authorization"] = "Bearer {cvY4PoZB8WZL1YznqKwGQ/+/Bef7kUUlxMHxs9tkTjbFC9Fk++QhjMRWKSyApHQzNA3qS0wBFiEkvE8E8/AbFbwHDSIx3SEn6/rhoyIuuUC3OFvOb3ws4YtvYrbE86s/g0YwW+pytU3xukr7QvosuAdB04t89/1O/w1cDnyilFU=}"
  if status == "success"
  request.body = JSON.dump({
    "to" => user_id,
    "messages" => [
      {
        "type" => "text",
        "text" => "登録しました！値下がり次第お伝えします。"
      }
    ]
  })
  else
    request.body = JSON.dump({
    "to" => user_id,
    "messages" => [
      {
        "type" => "text",
        "text" => "登録できませんでした。商品番号をもう一度お確かめください。"
      }
    ]
  })

  end

  req_options = {
    use_ssl: uri.scheme == "https",
  }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end
end

post '/callback' do
  item_url = params[:item_url]
  user_id = params[:user_id]
  reply_token = params[:reply_token]

  if item_url.include?("qoo10")
    begin
      p item_url
      detail_hash = Qoo10.new.parse_detail(item_url)
      Items.create(site_name: detail_hash["site_name"], item_url: item_url, item_name: detail_hash["item_name"], reference_price: detail_hash["reference_price"], normal_price: detail_hash["normal_price"], sale_price: detail_hash["sale_price"], affiliate_url: detail_hash["affiliate_url"], item_code: detail_hash["item_code"], selling_price: detail_hash["selling_price"], user_id: user_id, status: 0)
      reply(user_id, "success")
    rescue
      reply(user_id, "error")
    end
  elsif item_url.include?("rakuten")
    begin
      p item_url
      detail_hash = Rakuten.new.parse_detail(item_url)
      Items.create(site_name: detail_hash["site_name"], item_url: item_url, item_name: detail_hash["item_name"], reference_price: detail_hash["reference_price"], normal_price: detail_hash["normal_price"], sale_price: detail_hash["sale_price"], affiliate_url: detail_hash["affiliate_url"], item_code: detail_hash["item_code"], selling_price: detail_hash["selling_price"], user_id: user_id, status: 0)
      reply(user_id, "success")
    rescue
      reply(user_id, "error")
    end
  else
    reply(user_id, "error")
  end

end
