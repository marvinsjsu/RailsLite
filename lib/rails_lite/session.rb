require 'json'
require 'webrick'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    cookies = req.cookies
    my_cookie = cookies.select { |cookie| cookie.name == '_rails_lite_app' }[0]
    @cookie_values = {}
    @cookie_values = JSON.parse(my_cookie.value) unless my_cookie.nil?
  end

  def [](key)
    @cookie_values[key]
  end

  def []=(key, val)
    @cookie_values[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    values = @cookie_values.to_json
    values = {}.to_json if values.nil?
    new_cookie = WEBrick::Cookie.new('_rails_lite_app', values)
    res.cookies << new_cookie
  end
end
