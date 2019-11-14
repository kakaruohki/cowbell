require 'net/http'
require 'uri'
require 'json'

uri = URI.parse("https://api.line.me/v2/bot/message/push")
request = Net::HTTP::Post.new(uri)
request.content_type = "application/json"
request["Authorization"] = "Bearer {ten3h0WRpjVhhEZV9FdolF3LiyIR69ouWzxOm33EQIfnB9fqf+g7pepieZ+vBWgVNA3qS0wBFiEkvE8E8/AbFbwHDSIx3SEn6/rhoyIuuUBIcYqDc3sffjQe/mUalpWzm7tPLaTI4uXOJWUFlPqAVQdB04t89/1O/w1cDnyilFU=}"
request.body = JSON.dump({
  "to" => "U81161707b3dd33a74453f57b92ed832f",
  "messages" => [
    {
      "type" => "text",
      "text" => "値下がりしました！"
    },
    {
      "type" => "text",
      "text" => "https://www.qoo10.jp/su/429706046/Q132039868"
    }
  ]
})

req_options = {
  use_ssl: uri.scheme == "https",
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end

# response.code
# response.body
