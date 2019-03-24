require 'rspec-html-matchers'
require "./web-app"
require "rspec"
require "rack/test"

describe "web-app" do
    include RSpecHtmlMatchers
    include Rack::Test::Methods

    def app
        Sinatra::Application
    end

    it "returns status 200" do
        response = get "/"
        expect(response.status).to eq(200)
    end
    it "duration time check" do
        response = post "/recipe-duration-time", {id:1553394762, duration_time: 55}
        expect(response).to be_redirect
    end

    it "displays required time to prepare recipe" do
        response = get "/recipes/:id_recipe"
        expect(response.body).to match %r(duration_time)
    end

    it "has a 'form' tag to get a different preparation time from a user" do
        get "/recipes/1553393266"
        expect(last_response.body).to have_tag('form', :with => { :action => "/recipe-duration-time", :method => "POST" }) do
            with_tag "input", :with => { :name => "duration-time", :type => 'number' }
        end
    end

    it "displays average of inputs" do
        expect(prom([30, 40])).to eq(35)
    end
end