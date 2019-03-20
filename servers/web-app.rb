require "sinatra"
require "sinatra/reloader"
require "erb"

get "/" do
  redirect "/index"
end

get "/index" do
  erb :index
end

get "/login" do
 erb :login
end

get "/dash/:name" do
  erb :dash
end

get "/admin" do
  erb :admin
end

get "/search" do
  erb :search
end

get "/recipes" do
  erb :recipes
end

get "/add" do
  erb :add
end

get "/error" do
  erb :error
end

def store_name(filename, string)
  File.open(filename, "a+") do |file|
    file.puts([string])
  end
end

def authentic(username)
  user = File.read("user.txt")
  user.include?(username)
end

get "/login/:name" do
  @name = params["name"]
  erb :login
end

post "/login" do
  @name = params["name"]
  # store_name("user.txt", @name)
  if authentic(@name)
    redirect "/dash/#{@name}"
  else
    redirect "/error"
  end
end

set :port, 8000