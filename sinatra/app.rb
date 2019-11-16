require_relative '../common'
require_relative '../get_affiliate'

CHANNEL_ID = '1653480883'
CHANNEL_SECRET = '9b1fb9aeb218f04bafd51392755bf584'
CHANNEL_TOKEN = 'NRzTrAgRUl0a6mmkOCvpPRrCKxS5B/y4ACrPZaHtTCSrzyVVaebWZr857fd0Frx5NA3qS0wBFiEkvE8E8/AbFbwHDSIx3SEn6/rhoyIuuUBO5gHnXUwDFzCtDaTZxtx7Y5CMXuWZzzKEcG8RpzsUaQdB04t89/1O/w1cDnyilFU='

get '/' do
  "Hello world!"
end

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
        affiliate_url = Share.new.get_affiliate_url(item_code)
        detail_hash = Share.new.parse_detail(item_code)
        #affiliate_url = get_affiliate_url(item_code)
        #detail_hash = parse_detail(item_code)
        #Items.create(site_name: detail_hash["site_name"], item_name: detail_hash["item_name"], reference_price: detail_hash["reference_price"], normal_price: detail_hash["normal_price"], sale_price: detail_hash["sale_price"], affiliate_url: affiliate_url, item_code: item_code, selling_price: detail_hash["selling_price"], item_url: detail_hash["item_url"], user_id: user_id)
        message = {
          type: 'text',
          #text: event.message['text'] # オウム返し
          #text: event['source']['userId']
          text: "#{detail_hash["item_name"]}を登録しました！値下がり次第お伝えします。"
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
