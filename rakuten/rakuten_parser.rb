require_relative "../common"
require_relative "../selenium_helper"

class Rakuten < SeleniumHelper

  def initialize
    @sleep_time = sleep_time
    # Selenium::WebDriver::Chrome.driver_path = "/mnt/c/chromedriver.exe"
    ua = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.97 Safari/537.36"
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--user-agent=#{ua}')
    options.add_argument('--headless')
    options.add_argument('--disable-gpu')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-setuid-sandbox')
    options.add_argument('--proxy-server=http://5.1.53.46:8080')
    #options.add_argument('--proxy-server=http://178.48.68.189:8080')

    client = Selenium::WebDriver::Remote::Http::Default.new
    client.read_timeout = timeout_wait
    client.open_timeout = timeout_wait
    @session = Selenium::WebDriver.for :chrome, options: options, http_client: client
    @session.manage.timeouts.implicit_wait = timeout_wait
  end

  #商品詳細ページから商品番号を取得
  def parse_item_code(item_url)
    @session.navigate.to item_url
    switch_frame("#grp15_ias")
    sleep 2
    p html
    doc = Nokogiri::HTML.parse(html, nil, 'utf-8')
    item_code = doc.css("body > form > input[name=itemid]:nth-child(8)").attribute('value').text
    p item_code
    return item_code
  end

  #楽天APIより商品詳細情報を取得
  def parse_detail(item_url)
    RakutenWebService.configure do |c|
      c.application_id = ''
      c.affiliate_id = ''
    end

    item_code = parse_item_code(item_url)
    detail_hash = {}
    items = RakutenWebService::Ichiba::Item.search(:itemCode => item_code)
    items.first(1).each do |item|
      detail_hash = {"site_name" => "rakuten", "item_code" => item_code, "item_name" => item['itemName'], "affiliate_url" => item['affiliateUrl'], "reference_price" => "", "normal_price" => "", "sale_price" => "", "selling_price" => item['itemPrice']}
    end
    detail_hash
  end

  #現在の値段を取得し、下がっていれば通知
  def check_price
    item_arr = Items.select("id, site_name, item_code, selling_price, affiliate_url, user_id, status").all
    item_arr.each do |item_hash|
      next if item_hash["status"] == 1 || !(item_hash["site_name"] == "rakuten")
      item_code = item_hash["item_code"]
      user_id = item_hash["user_id"]
      selling_price = item_hash["selling_price"]
      affiliate_url = item_hash["affiliate_url"]

      RakutenWebService.configure do |c|
        c.application_id = ''
        c.affiliate_id = ''
      end
      present_item_hash = {}
      items = RakutenWebService::Ichiba::Item.search(:itemCode => item_code)
      items.first(1).each do |item|
        present_item_hash = {"site_name" => "rakuten", "item_name" => item['itemName'], "affiliate_url" => item['affiliateUrl'], "reference_price" => "", "normal_price" => "", "sale_price" => "", "selling_price" => item['itemPrice']}
      end

      present_price = present_item_hash["selling_price"]
      Items.find_by(id: item_hash["id"]).update(status: 1) if present_price.to_i < selling_price
      post(user_id, affiliate_url) if present_price.to_i < selling_price
    end
  end

  #値下げ時のプッシュ通知
  def post(user_id, affiliate_url)
    uri = URI.parse("https://api.line.me/v2/bot/message/push")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Bearer {cvY4PoZB8WZL1YznqKwGQ/+/Bef7kUUlxMHxs9tkTjbFC9Fk++QhjMRWKSyApHQzNA3qS0wBFiEkvE8E8/AbFbwHDSIx3SEn6/rhoyIuuUC3OFvOb3ws4YtvYrbE86s/g0YwW+pytU3xukr7QvosuAdB04t89/1O/w1cDnyilFU=}"
    request.body = JSON.dump({
      "to" => user_id,
      "messages" => [
        {
          "type" => "text",
          "text" => "値下がりしました！"
        },
        {
          "type" => "text",
          "text" => affiliate_url
        }
      ]
    })

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
  end

end

item_url = "https://item.rakuten.co.jp/adidas/ed7350/?iasid=07rpp_10096___ec-k3rbx0uy-8opr-2bc63514-6304-4705-894b-cdc415d8cad2"
item_url = "https://item.rakuten.co.jp/sportszyuen/cq1962-l/"
#pp Rakuten.new.check_price
pp Rakuten.new.parse_detail(item_url)
