require_relative './web-app'
require "rspec"
require "rack/test"
require 'rspec-html-matchers'

describe "web-app" do
  include Rack::Test::Methods
  include RSpecHtmlMatchers

  def app
    Sinatra::Application
  end

  it "returns status 200 when we find an specific image uploaded in our web-app" do
    response = get "/images/chaufa.jpg"
    expect(response.status).to eq(200)
  end

  it "show url images" do
    response = get "/recipes/1553393266"
    expect(response.body).to have_tag("pre", /\/images\//)
  end

  it "imagen uploaded check in specific user" do
    response = get "/recipes/1553394762", params = {"image" => "/images/lomo1.jpg"}
    puts response
    expect(response.status).to eq(200)
  end

end





