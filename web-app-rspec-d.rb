# require "./web-app"
require_relative './web-app'
require "rspec"
require "rack/test"

describe "web-app" do
 include Rack::Test::Methods

 def app
   Sinatra::Application
 end

it "returns status 200" do
    response = get "/"
    expect(response.status).to eq(200)
  end

  it "returns status 302" do
    response = post "/recipe-quality", { id: 1553397486, quality: 3 }
    puts response
    expect(response.status).to be(302)
   end

  it "test difficult" do
   respn = post "/recipe-difficulty", { id: 1553394762, difficult: 2}
   expect(respn).to be_redirect
  end

end
