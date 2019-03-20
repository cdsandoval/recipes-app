require "sinatra"
require "erb"

get "/" do
  erb :index, { :layout => :base }
end

get "/access" do
 erb :access, { :layout => :base }
end

get "/dashboard/:name" do
  erb :dashboard, { :layout => :base }
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

# get "/access/:name" do
#   @name = params["name"]
#   erb :access
# end

post "/access" do
  @name = params["name"]
  # store_name("user.txt", @name)
  if authentic(@name)
    redirect "/dashboard/#{@name}"
  else
    redirect "/error"
  end
end

set :port, 8000