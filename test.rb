require 'net/http'
require 'uri'
require 'json'

uri = URI.parse("https://m.qoo10.jp/gmkt.inc/swe_MemberAjaxService.asmx/GetSnsShortUrl")
request = Net::HTTP::Post.new(uri)
request.content_type = "application/json"
request["Host"] = "m.qoo10.jp"
request["Cookie"] = "ezview=; m_w=345; MobileRefererByCookie=https%3a%2f%2fm.qoo10.jp%2fgmkt.inc%2fmobile%2fgoods%2fgoods.aspx%3fgoodscode%3d669944056%26referer_page_no%3d580%26flowpath_page_no%3d580; _fbp=fb.1.1572568922434.1541310788; _ga=GA1.2.1605150193.1572568922; _gid=GA1.2.1386218150.1572689692; etc_info=shop_cd=580&class_cd=&class_kind=D; item_view_female=2; lastViewGoods=669944056:1355492280:1128; first_sid=1422; landing-flowpath-info=579%7c--%7c%7c--%7cD; viewed_special=1422; affiliate_app_purchase=Tg%3d%3d; affiliate_co_code=MTAwMDAwNTI5; affiliate_group_id=MTMw; gmktLang=ja; inflow_referer=direct; jaehu_id=MjAwMDA4Njkx; jaehu_id_sub_value=; jaehu_id_sub_value2=; referrer_svc_nation_cd=JP; tracking-devcd-5=iPhone%3a%3aIOS_12.2%3a%3aSafari_Gmarket_Qoo10_JP%3a%3aMobile; tracking-landing-page=1652!%3a%3a!; __gads=Test; _wp_uid=1-36914f0930c0b47ff376672e086176e8-s1572690052.9553|iphone|webview-1t2ja9b; cto_lwid=0017d5ee-37ad-4fe3-9a48-84e3cc20734a; user_info=gender=F; _gcl_au=1.1.639641065.1572568922"
request["Accept"] = "*/*"
request["Origin"] = "https://m.qoo10.jp"
request["Accept-Language"] = "ja-jp"
request["User-Agent"] = "Mozilla/5.0 (iPhone; CPU iPhone OS 12_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 iPhone_Gmarket Qoo10 JP_4.1.7_4(GMKTV2_s51t_g_1_fNnKJKcLBIZguBnScwVLV4y5da9zFTi8Z7DWqTqYwX1dmWE5_g_1_uNtKsGjxnZ2l4naNv3vQc_g_3_;iPhone10,1;iOS 12.2;ja_JP;200008691)"
request["Referer"] = "https://m.qoo10.jp/gmkt.inc/Mobile/Goods/goods.aspx?goodscode=669944056&referer_page_no=580&flowpath_page_no=580"
request.body = JSON.dump({
  "login_id" => "",
  "title" => "[Qoo10] ワイヤレスイヤホン",
  "share_url" => "https://m.qoo10.jp/gmkt.inc/Mobile/Goods/goods.aspx?goodscode=669944056",
  "picture" => "https://gd.image-qoo10.jp/li/280/492/1355492280.g_400-w-st_g.jpg",
  "sell_price" => 0,
  "sns_cd" => "",
  "connect_yn" => "n",
  "affiliate_contract_cd" => "",
  "message" => "[Qoo10] ワイヤレスイヤホン",
  "___cache_expire___" => "1572706429318"
})

req_options = {
  use_ssl: uri.scheme == "https",
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end

# response.code
pp response.body
