require 'net/http'
require 'uri'

def handler(event:, context:)
  env = ENV['RAILS_ENV'] 
  domain = "#{env}.example.come"
  uri = URI("https://#{domain}/healthcheck")
  response = Net::HTTP.get_response(uri)
  puts response
  puts "============"
  { statusCode: response.code, body: response.body }
end