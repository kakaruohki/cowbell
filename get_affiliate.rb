require_relative "common"
require_relative "selenium_helper"

class Share < SeleniumHelper

  def login
    @session.navigate.to "https://www.qoo10.jp/gmkt.inc/Login/Login.aspx"
    query_click("#dv_fb_go > a.btn_gg")
    @session.switch_to.window(@session.window_handles.last)
    send_value("#Email", "kakeru.ohki@gmail.com")
    query_click("#next")
    sleep 1
    send_value("#Passwd", "19970922")
    query_click("#signIn")
    binding.pry
    @session.switch_to.window(@session.window_handles.last)
    switch_frame("#frame_popup")
    binding.pry
    send_value("#email", "kakeru.ohki@gmail.com")
    query_click("#aspnetForm > div > div > div.btn_area > a:nth-child(1)")
    #query_click("#dv_member_login > span.login_btn_ara > a")
    sleep_designated
  end

  def move_to_detail_page(item_code)
    login_cookie
    #@session.navigate.to "https://www.qoo10.jp/"
    send_value("input.ip_text", item_code)
    query_click("button.btn")
    query_click("a#btn_close") if css_exist?("a#btn_close")
    query_click("div.sbj > a[data-type=goods_url]")
  end

  def get_affiliate_url(item_code)
    move_to_detail_page(item_code)
    @session.switch_to.window(@session.window_handles.last)
    query_click("a#btn_close") if css_exist?("a#btn_close")
    charset = nil
    doc = Nokogiri::HTML.parse(html, nil, charset)
    item_name = doc.css("h2#goods_name").text
    #item_code = doc.css("div.code").text.match(/\w+/)[0]
    #item_url = @session.current_url
    reference_price = doc.css("div#ctl00_ctl00_MainContentHolder_MainContentHolderNoForm_retailPricePanel > dl > dd").text.gsub(/円|,/,"")
    normal_price = doc.css("#dl_sell_price > dd > strong").text.gsub(/円|,/,"")
    sale_price = doc.css("dl.detailsArea.q_dcprice > dd").text.gsub(/\(.+\)|\s|\W|,/,"")
    @session.quit
    selling_price = normal_price
    selling_price = sale_price unless sale_price.blank?
    #return {"site_name" => "Qoo10", "item_name" => item_name, "reference_price" => reference_price, "normal_price" => normal_price, "sale_price" => sale_price}

    query_click("#div_Default_Image > div.fctn_area > div.fctn > ul > li.bul_share > a")
    #sleep_designated
    @session.switch_to.window(@session.window_handles.last)
    sleep 1
    charset = nil
    doc2 = Nokogiri::HTML.parse(html, nil, charset)
    affiliate_url = doc2.css("#lnk_url").text
    #p affiliate_url
    @session.quit
    return {"site_name" => "Qoo10", "item_name" => item_name, "affiliate_url" => affiliate_url, "reference_price" => reference_price, "normal_price" => normal_price, "sale_price" => sale_price, "selling_price" => selling_price, "item_url" => item_url}
  end

  def parse_detail(item_code)
    move_to_detail_page(item_code)
    @session.switch_to.window(@session.window_handles.last)
    query_click("a#btn_close") if css_exist?("a#btn_close")
    charset = nil
    doc = Nokogiri::HTML.parse(html, nil, charset)
    item_name = doc.css("h2#goods_name").text
    #item_code = doc.css("div.code").text.match(/\w+/)[0]
    #item_url = @session.current_url
    reference_price = doc.css("div#ctl00_ctl00_MainContentHolder_MainContentHolderNoForm_retailPricePanel > dl > dd").text.gsub(/円|,/,"")
    normal_price = doc.css("#dl_sell_price > dd > strong").text.gsub(/円|,/,"")
    sale_price = doc.css("dl.detailsArea.q_dcprice > dd:nth-of-type(1)").text.gsub(/\(.+\)|\s|\W|,/,"")
    sale_price = doc.css("ul.infoArea > li.infoData:nth-of-type(1) dl:nth-of-type(2)").text.gsub(/\(.+\)|\s|\W|,/,"") if sale_price.blank?
    #@session.quit
    selling_price = normal_price
    selling_price = sale_price unless sale_price.blank?
    query_click("#div_Default_Image > div.fctn_area > div.fctn > ul > li.bul_share > a")
    #sleep_designated
    @session.switch_to.window(@session.window_handles.last)
    sleep 1.5
    charset = nil
    doc2 = Nokogiri::HTML.parse(html, nil, charset)
    affiliate_url = doc2.css("#lnk_url").text
    @session.quit
    #return {"site_name" => "Qoo10", "item_name" => item_name, "reference_price" => reference_price, "normal_price" => normal_price, "sale_price" => sale_price}
    return {"site_name" => "Qoo10", "item_name" => item_name, "affiliate_url" => affiliate_url, "reference_price" => reference_price, "normal_price" => normal_price, "sale_price" => sale_price, "selling_price" => selling_price}
  end

  =begin

    def check_price(item_code)
      move_to_detail_page(item_code)
      @session.switch_to.window(@session.window_handles.last)
      charset = nil
      doc = Nokogiri::HTML.parse(html, nil, charset)
      item_name = doc.css("h2#goods_name").text
      present_price = doc.css("#dl_sell_price > dd > strong").text.gsub(/円|,/,"")
      present_price = doc.css("dl.detailsArea.q_dcprice > dd").text.gsub(/\(.+\)|\s|円|,/,"") unless doc.css("dl.detailsArea.q_dcprice > dd").blank?
      #price = Items.select(:price).where(item_code: item_code)
      item_hash = {"item_name" => item_name, "item_code" => item_code, "sale_price" => present_price}
      alert unless record_existing?(Items, item_hash)
    end

  =end
  def check_price
    #present_price = nil
    #selling_price = nil
    #user_id = nil
    item_arr = Items.select("id, item_url, selling_price, user_id, affiliate_url, status").all
    item_arr.each do |item_hash|
      next if item_hash["status"] == 1
      #item_url = item_hash["item_url"]
      user_id = item_hash["user_id"]
      selling_price = item_hash["selling_price"]
      affiliate_url = item_hash["affiliate_url"]
      #@session.navigate.to item_url
      #binding.pry
      @session.navigate.to affiliate_url
      sleep 1
      doc = Nokogiri::HTML.parse(html, nil, nil)
      #item_name = doc.css("h2#goods_name").text
      #item_code = doc.css("div.code").text.match(/\w+/)[0]
      item_url = @session.current_url
      reference_price = doc.css("div#ctl00_ctl00_MainContentHolder_MainContentHolderNoForm_retailPricePanel > dl > dd").text.gsub(/円|,/,"")
      normal_price = doc.css("#dl_sell_price > dd > strong").text.gsub(/円|,/,"")
      #sale_price = doc.css("dl.detailsArea.q_dcprice > dd").text.gsub(/\(.+\)|\s|\W|,/,"")
      #sale_price = doc.css("#sp_max_dc_price").text.gsub(/\(.+\)|\s|\W|,/,"")
      sale_price = doc.css("dl.detailsArea.q_dcprice > dd:nth-of-type(1)").text.gsub(/\(.+\)|\s|\W|,/,"")
      sale_price = doc.css("ul.infoArea > li.infoData:nth-of-type(1) dl:nth-of-type(2)").text.gsub(/\(.+\)|\s|\W|,/,"") if sale_price.blank?
      #@session.quit
      sleep 1
      present_price = normal_price
      present_price = sale_price unless sale_price.blank?
      Items.find_by(id: item_hash["id"]).update(status: 1) if present_price.to_i < selling_price
      post(user_id, affiliate_url) if present_price.to_i < selling_price
    end
    #binding.pry
    #post(user_id, affiliate_url) if present_price.to_i < selling_price
  end

  #def alert(user_id)
  #  #通知
  #  Users
  #end
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

  def record_existing?(class_name,item)
    hash = {
      item_name: item["item_name"],
      #site_name: item["site_name"],
      item_code: item["item_code"],
      sale_price: item["sale_price"] #selling_price以外取得する？
    }
    hash.each do |item_key,item_value|
        hash.delete(item_key) if item_value.nil?
    end
    same_record = class_name.find_by(hash)
    same_record.present?
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

end

url = "https://www.qoo10.jp/item/%E8%B2%A9%E5%A3%B2%EF%BC%91%E4%BD%8D-%E5%BA%97-%E5%88%A9%E7%94%A8%E5%8F%AF%E8%83%BD%E3%81%AA%E3%82%AF%E3%83%BC%E3%83%9D%E3%83%B3MICROSOFT-OFFICE-2019-PROFESSIONAL-1PC%E7%94%A8-%E6%97%A5%E6%9C%AC%E8%AA%9E%E3%83%80%E3%82%A6%E3%83%B3%E3%83%AD%E3%83%BC%E3%83%89%E7%89%88/474767106?stcode=411#none"
item_code = "620883278"
item_code = "あ"
#pp Share.new.check_price
#pp Share.new.get_affiliate_url(item_code)
#pp Share.new.login_cookie
#Share.new.parse_detail(item_code)
#Share.new.check_price(item_code)
#Share.new.check_price
#affiliate_url = Share.new.get_affiliate_url(item_code)
#p 1
#detail_hash = Share.new.parse_detail(item_code)
#p 2
#Items.create(site_name: detail_hash["site_name"], item_name: detail_hash["item_name"], reference_price: detail_hash["reference_price"], normal_price: detail_hash["normal_price"], sale_price: detail_hash["sale_price"], affiliate_url: affiliate_url, item_code: item_code)
                                                                                                                                                                245,5         Bot
