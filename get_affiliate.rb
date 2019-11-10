require_relative "common"
require_relative "selenium_helper"

class Share < SeleniumHelper

  def login
    @session.navigate.to "https://www.qoo10.jp/gmkt.inc/Login/Login.aspx"
    send_value("input[name=login_id]", "kakeru.ohki@gmail.com")
    send_value("input[name=passwd]", "okkr1154")
    query_click("#dv_member_login > span.login_btn_ara > a")
    sleep_designated
  end

  def move_to_detail_page(item_code)
    login
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
    present_price = nil
    selling_price = nil
    user_id = nil
    item_arr = Items.select("item_url, selling_price, user_id").all
    item_arr.each do |item_hash|
      item_url = item_hash["item_url"]
      selling_price = item_hash["selling_price"]
      @session.navigate.to item_url
      doc = Nokogiri::HTML.parse(html, nil, nil)
      item_name = doc.css("h2#goods_name").text
      #item_code = doc.css("div.code").text.match(/\w+/)[0]
      item_url = @session.current_url
      reference_price = doc.css("div#ctl00_ctl00_MainContentHolder_MainContentHolderNoForm_retailPricePanel > dl > dd").text.gsub(/円|,/,"")
      normal_price = doc.css("#dl_sell_price > dd > strong").text.gsub(/円|,/,"")
      sale_price = doc.css("dl.detailsArea.q_dcprice > dd").text.gsub(/\(.+\)|\s|\W|,/,"")
      #binding.pry
      @session.quit
      present_price = normal_price
      present_price = sale_price unless sale_price.blank?
    end
    alert(user_id) if present_price.to_i < selling_price
  end

  def alert(user_id)
    #通知
    Users

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

end

url = "https://www.qoo10.jp/item/%E8%B2%A9%E5%A3%B2%EF%BC%91%E4%BD%8D-%E5%BA%97-%E5%88%A9%E7%94%A8%E5%8F%AF%E8%83%BD%E3%81%AA%E3%82%AF%E3%83%BC%E3%83%9D%E3%83%B3MICROSOFT-OFFICE-2019-PROFESSIONAL-1PC%E7%94%A8-%E6%97%A5%E6%9C%AC%E8%AA%9E%E3%83%80%E3%82%A6%E3%83%B3%E3%83%AD%E3%83%BC%E3%83%89%E7%89%88/474767106?stcode=411#none"
item_code = "620883278"
#Share.new.get_affiliate_url(item_code)
#Share.new.parse_detail(item_code)
#Share.new.check_price(item_code)
#Share.new.check_price
