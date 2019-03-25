require 'rspec-html-matchers'
require "./web-app"
require "rspec"
require "rack/test"

RECIPE_STEP1 = {
  "id_user": "66",
  "name": "Este name es taaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaan largo que tiene más de 80 caracteres",
  "difficult": "2",
  "duration_time": "35",
  "quality": "3",
  "steps": "2"
}

describe "web-app" do
  include RSpecHtmlMatchers
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "Title of recipe is limited to 80 characters" do
    response = post "/add-recipe", RECIPE_STEP1
    name_size = Rack::Utils.parse_query(response.location)["name"].size
    puts Rack::Utils.parse_query(response.location)["name"]
    expect(name_size).to be < 81
  end

  it "Recipes contains img with valid source" do
    response = get "/recipes/1553393266"
    expect(response.body).to have_tag("img[src!='']")
  end

  it "Recipes contains description's text" do
    response = get "/recipes/1553393266"
    expect(response.body).to have_tag("div.description") do
      but_without_text ""
    end
  end


end
