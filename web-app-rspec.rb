require "./web-app"
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

    it "quality check" do
        response = post "/recipe-quality", {id: 1553269523, quality: 3}
        expect(response).to be_redirect
    end

    it "duration time check" do
        response = post "/recipe-duration-time", {id:1553269523, duration_time: 4192}
        expect(response).to be_redirect
    end

    it "duration time check" do
        response = post "/recipe-duration-time", {id:1553288224, duration_time: 2096}
        expect(response).to be_redirect
    end
end