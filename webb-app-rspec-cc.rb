require_relative './web-app'
require "rspec"
require "rack/test"
require 'rspec-html-matchers'

describe "web-app" do
  include Rack::Test::Methods
  include RSpecHtmlMatchers
  include ActionDispatch::TestProcess
  
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
    response = get "/recipes/1553465621", params = {"image" => "/images/pollosillao1.png"}
    puts response
    expect(response.status).to eq(200)
  end

  # it "can upload a license" do
  #   # @filename = save_image('/images/')
  #   post :uploadLicense, :upload => @filename
  #   response.should be_success
  #   puts response
  #   expect(response.status).to eq(200)
  # end

  # it "can upload a license" do
  #   file = Hash.new
  #   file['datafile'] = @file
  #   post :uploadLicense, :upload => file
  #   response.should be_success
  end
end





