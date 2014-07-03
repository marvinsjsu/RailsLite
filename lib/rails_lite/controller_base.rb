require 'erb'
require 'active_support/inflector'
require 'json'
require_relative 'params'
require_relative 'session'

class ControllerBase

  attr_reader :params, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = Params.new(req, route_params)
    @session = Session.new(@req)
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    raise "response has already been built" if already_built_response?
    @res.content_type = type
    @res.body = content
    @session.store_session(res)
    @already_built_response = true
  end

  # helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # set the response status code and header
  def redirect_to(url)
    raise "response has already been built" if already_built_response?
    @res.status = 302
    @res.header["location"] = url
    @session.store_session(res)
    @already_built_response = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_name = self.class.name.underscore
    f = File.read("views/#{controller_name}/#{template_name}.html.erb")
    erb_template = ERB.new(f).result(binding)
    render_content(erb_template, "text/html")
  end

  # method exposing a `Session` object
  def session
    @session ||= @req.cookies.select { |cookie| cookie.name == '_rails_lite_app' }
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    send(name)
    render(name) unless already_built_response?
  end
end
