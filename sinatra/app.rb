#require_relative '../common'
#require_relative '../get_affiliate'
require 'optparse'
require 'pry'
require 'sinatra'
require 'line/bot'
require 'active_record'
require 'logger'
require 'bundler'

CHANNEL_ID = '1653480883'
CHANNEL_SECRET = '9b1fb9aeb218f04bafd51392755bf584'
CHANNEL_TOKEN = 'NRzTrAgRUl0a6mmkOCvpPRrCKxS5B/y4ACrPZaHtTCSrzyVVaebWZr857fd0Frx5NA3qS0wBFiEkvE8E8/AbFbwHDSIx3SEn6/rhoyIuuUBO5gHnXUwDFzCtDaTZxtx7Y5CMXuWZzzKEcG8RpzsUaQdB04t89/1O/w1cDnyilFU='

helpers do
  def html(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  "Hello world!"
end

#class SeleniumHelper
  attr_accessor :session
  attr_accessor :sleep_time
  attr_accessor :timeout_wait
  #def initialize(sleep_time: 1)
    @sleep_time = sleep_time
    # Selenium::WebDriver::Chrome.driver_path = "/mnt/c/chromedriver.exe"
    ua = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.97 Safari/537.36"
    # caps = Selenium::WebDriver::Remote::Capabilities.chrome("chromeOptions" => {args: ["--headless","--no-sandbox", "--disable-setuid-sandbox", "--disable-gpu", "--user-agent=#{ua}", 'window-size=1280x800']})
    # caps = Selenium::WebDriver::Remote::Capabilities.chrome("chromeOptions" => {args: ["--user-agent=#{ua}", "window-size=1280x800"]})
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--user-agent=#{ua}')
    #options.add_argument('--headless')
    options.add_argument('--disable-gpu')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-setuid-sandbox')
    client = Selenium::WebDriver::Remote::Http::Default.new
    client.read_timeout = timeout_wait
    client.open_timeout = timeout_wait
    @session = Selenium::WebDriver.for :chrome, options: options, http_client: client
    @session.manage.timeouts.implicit_wait = timeout_wait
  #end

def timeout_wait
    return 300 if @timeout_wait.nil?
    @timeout_wait
  end

  def sleep_designated
    sleep @sleep_time
  end

  def query_click(css_selector)
    javascript_statement = %Q{document.querySelector("#{css_selector}").click()}
    @session.execute_script(javascript_statement)
    sleep_designated
    self
  end

  def switch_frame(*css_selectors)
    @session.switch_to.window @session.window_handle
    css_selectors.each do |css_selector|
      iframe = @session.find_element(:css,css_selector)
      @session.switch_to.frame(iframe)
    end
  end

  def css_exist?(css_selector)
    rescue_session = @session
    rescue_session.manage.timeouts.implicit_wait = 5
    rescue_session.find_elements(:css,css_selector).present?
  end

  def send_value(css_selector,value)
    javascript_statement = %Q{document.querySelector("#{css_selector}").value = "#{value}"}
    @session.execute_script(javascript_statement)
  end

  def html
    @session.page_source
  end
#end

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_id     = CHANNEL_ID
    config.channel_secret = CHANNEL_SECRET
    config.channel_token  = CHANNEL_TOKEN
  }
end

def get_userid
  body = request.body.read
  events = client.parse_events_from(body)
  events.each { |event|
    userId = event['source']['userId']  #userId取得
    p "UserID: #{userId}" # UserIdを確認
  }
  return userId
end
#class Share < SeleniumHelper
def move_to_detail_page(item_code)
  login_cookie
  #@session.navigate.to "https://www.qoo10.jp/"
  send_value("input.ip_text", item_code)
  query_click("button.btn")
  sleep_designated
  query_click("a#btn_close") if css_exist?("a#btn_close")
  query_click("div.sbj > a[data-type=goods_url]")
  sleep_designated
end

def get_affiliate_url(item_code)
  move_to_detail_page(item_code)
  @session.switch_to.window(@session.window_handles.last)
  query_click("#div_Default_Image > div.fctn_area > div.fctn > ul > li.bul_share > a")
  sleep_designated
  @session.switch_to.window(@session.window_handles.last)
  sleep 3
  charset = nil
  doc = Nokogiri::HTML.parse(html, nil, charset)
  affiliate_url = doc.css("#lnk_url").text
  @session.quit
  return affiliate_url
end

def parse_detail(item_code)
  move_to_detail_page(item_code)
  @session.switch_to.window(@session.window_handles.last)
  query_click("a#btn_close") if css_exist?("a#btn_close")
  charset = nil
  doc = Nokogiri::HTML.parse(html, nil, charset)
  item_name = doc.css("h2#goods_name").text
  #item_code = doc.css("div.code").text.match(/\w+/)[0]
  item_url = @session.current_url
  reference_price = doc.css("div#ctl00_ctl00_MainContentHolder_MainContentHolderNoForm_retailPricePanel > dl > dd").text.gsub(/円|,/,"")
  normal_price = doc.css("#dl_sell_price > dd > strong").text.gsub(/円|,/,"")
  sale_price = doc.css("dl.detailsArea.q_dcprice > dd").text.gsub(/\(.+\)|\s|\W|,/,"")
  @session.quit
  selling_price = normal_price
  selling_price = sale_price unless sale_price.blank?
  #return {"site_name" => "Qoo10", "item_name" => item_name, "reference_price" => reference_price, "normal_price" => normal_price, "sale_price" => sale_price}
  return {"site_name" => "Qoo10", "item_name" => item_name, "reference_price" => reference_price, "normal_price" => normal_price, "sale_price" => sale_price, "selling_price" => selling_price, "item_url" => item_url}
end

def login_cookie
  @session.navigate.to "https://www.qoo10.jp/gmkt.inc/"
  cookies = [{:name=>"landing-flowpath-info", :value=>"111%7c--%7c%7c--%7cT", :path=>"/", :domain=>".qoo10.jp", :expires=>nil, :secure=>false},
             {:name=>"etc_info", :value=>"shop_cd=111&class_cd=&class_kind=T", :path=>"/", :domain=>".qoo10.jp", :expires=>nil, :secure=>false},
             {:name=>"is_popup_login", :value=>"N", :path=>"/", :domain=>".qoo10.jp", :expires=>nil, :secure=>false},
             {:name=>"ck_login_sc", :value=>"Y", :path=>"/", :domain=>".qoo10.jp", :secure=>false},
             {:name=>"new_msg_cnt", :value=>"1", :path=>"/", :domain=>".qoo10.jp", :secure=>false},
             {:name=>"ezwish", :value=>"", :path=>"/", :domain=>".qoo10.jp", :expires=>nil, :secure=>false},
             {:name=>"global_info", :value=>"user_confirm_info=V1:vFGLABPxr+R5JqokYNPm4wNYrhAbaZBciDfqNk4JvFc=&global_link_yn=N&mecox_member_yn=N", :path=>"/", :domain=>".qoo10.jp"},
             {:name=>"save_login_id", :value=>"kakeru.ohki@gmail.com", :path=>"/", :domain=>".qoo10.jp", :secure=>false},
             {:name=>"affiliate_group_id", :value=>"MTY5", :path=>"/", :domain=>".qoo10.jp", :secure=>false},
             {:name=>"_fbp", :value=>"fb.1.1574231310732.453091575", :path=>"/", :domain=>".qoo10.jp", :secure=>false},
             {:name=>"GMKT.FRONT.JP",:value=>"44E2890FC8716348798818F8703F4A4169CD910F62E999BBF9DA640127C78D21AD7F0A9E15A5F8B51351DA807DA2B98383CB5FDBA122B9C6726AF7D852689FD6A2C84BD3803ECBD86FFF36FB693F675029FB6A542AC888204FAFD5D6BD477FCA63742B5555248B4068D76DF315DA5BC0AD00E7748DC76370C10143953DD4E151C50518233F81673F14D5777C3A4942973DAFBACC654E7F1496246DA5A83738AE7B9F1CDBB5F8C6FB112B48925C5B9881290B27117316C02A123CA534680378589EAED9580036EA3750AABC55EFEE7E36C168A8A1E709930DF7FFA3109FA7014701AD92C1E08CF3278736DDDB5EFE2C5649E70D65C03762D430D79DE05ABC23FC44D6B6E79D6C6A657006A143A02505953E5F8325EC76DFB8C7F272E845ABB6DBBB7849D1E7EC2CC807A289C580063850CF314D33B63664DDF2D813FA40922A1CF456A21B95C27B64E797435F56835A70DB6E9D15A6809835061158021FEAFBF98CDD507A6DA8258346BCC4E55C8C7C3D2ADC4ED5", :path=>"/", :domain=>".qoo10.jp", :secure=>true},
             {:name=>"hist_back", :value=>"null", :path=>"/", :domain=>".qoo10.jp", :expires=>nil, :secure=>false},
             {:name=>"_gcl_au", :value=>"1.1.1567726418.1574231311", :path=>"/", :domain=>".qoo10.jp", :secure=>false},
             {:name=>"_gat_UA-120215988-1", :value=>"1", :path=>"/", :domain=>".qoo10.jp", :secure=>false},
             {:name=>"tracking-sessionid", :value=>"f1d46cf1-3134-402c-a9f6-c605ec4cd2d4::2019-11-20 15:28:28", :path=>"/", :domain=>".qoo10.jp", :secure=>false},
             {:name=>"user_info", :value=>"gender=M", :path=>"/", :domain=>".qoo10.jp", :secure=>false},
             {:name=>"_gid", :value=>"GA1.2.610929334.1574231311", :path=>"/", :domain=>".qoo10.jp", :secure=>false},
             {:name=>"jaehu_id", :value=>"MjAwMDE0NjQ0OQ%3d%3d", :path=>"/", :domain=>".qoo10.jp", :secure=>false},
             {:name=>"affiliate_co_code", :value=>"MTAwMDAwNzY0", :path=>"/", :domain=>".qoo10.jp", :secure=>false},
             {:name=>"tracking-landing-page", :value=>"54!%3a%3a!", :path=>"/", :domain=>".qoo10.jp", :expires=>nil, :secure=>false},
             {:name=>"affiliate_app_purchase", :value=>"Tg%3d%3d", :path=>"/", :domain=>".qoo10.jp", :secure=>false},
             {:name=>"SPECIAL_SHOP_SITE_ID", :value=>"", :path=>"/", :domain=>".qoo10.jp", :expires=>nil, :secure=>false},
             {:name=>"ezview", :value=>"620883278!0:1104830823:31000:0", :path=>"/", :domain=>".qoo10.jp", :expires=>nil, :secure=>false},
             {:name=>"ez_ct", :value=>"0", :path=>"/", :domain=>".qoo10.jp", :expires=>nil, :secure=>false},
             {:name=>"jaehu_id_sub_value2", :value=>"", :path=>"/", :domain=>".qoo10.jp", :secure=>false},
             {:name=>"referrer_svc_nation_cd", :value=>"JP", :path=>"/", :domain=>".qoo10.jp", :expires=>nil, :secure=>false},
             {:name=>"_ga", :value=>"GA1.2.1510627820.1574231311", :path=>"/", :domain=>".qoo10.jp", :secure=>false},
             {:name=>"jaehu_id_sub_value", :value=>"", :path=>"/", :domain=>".qoo10.jp", :secure=>false},
             {:name=>"inflow_referer", :value=>"direct", :path=>"/", :domain=>".qoo10.jp", :expires=>nil, :secure=>false},
             {:name=>"tracking-devcd-5", :value=>"Unknown", :path=>"/", :domain=>".qoo10.jp", :expires=>nil, :secure=>false}]
  cookies.each do |cookie|
    @session.manage.add_cookie(cookie)
  end
  @session.navigate.to "https://www.qoo10.jp/gmkt.inc/"
  #get_affiliate_url("620883278")
end
#end
#require_relative '../get_affiliate'


post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  events.each { |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        item_code = event.message['text']
        user_id = event['source']['userId']
        #affiliate_url = Share.new.get_affiliate_url(item_code)
        #detail_hash = Share.new.parse_detail(item_code)
        affiliate_url = get_affiliate_url(item_code)
        detail_hash = parse_detail(item_code)
        #affiliate_url = get_affiliate_url(item_code)
        #detail_hash = parse_detail(item_code)
        #Items.create(site_name: detail_hash["site_name"], item_name: detail_hash["item_name"], reference_price: detail_hash["reference_price"], normal_price: detail_hash["normal_price"], sale_price: detail_hash["sale_price"], affiliate_url: affiliate_url, item_code: item_code, selling_price: detail_hash["selling_price"], item_url: detail_hash["item_url"], user_id: user_id)
        message = {
          type: 'text',
          text: event.message['text'] # オウム返し
          #text: event['source']['userId']
          #text: "#{detail_hash["item_name"]}を登録しました！値下がり次第お伝えします。"
          #text: "#{affiliate_url}"
        }

        #item_code = event.message['text']
        #user_id = event['source']['userId']
        #affiliate_url = Share.get_affiliate_url(item_code)
        #detail_hash = Share.parse_detail(item_code)
        #Items.create(site_name: detail_hash["site_name"], item_name: detail_hash["item_name"], reference_price: detail_hash["reference_price"], normal_price: detail_hash["normal_price"], sale_price: detail_hash["sale_price"], affiliate_url: affiliate_url, item_code: item_code, selling_price: detail_hash["selling_price"], item_url: detail_hash["item_url"], user_id: user_id)

        client.reply_message(event['replyToken'], message)
      when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
        response = client.get_message_content(event.message['id'])
        tf = Tempfile.open("content")
        tf.write(response.body)
      end
    end
  }

  # Don't forget to return a successful response
  "OK"
end
