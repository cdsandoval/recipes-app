require "sinatra"
require "erb"
require "sinatra/reloader"

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

get "/recipe" do
  erb :recipe, { :layout => :base }
end

get "/add-recipe" do
  erb :add_recipe, { :layout => :base }
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

post "/access" do
  @name = params["name"]
  # store_name("user.txt", @name)
  if authentic(@name)
    redirect "/dashboard/#{@name}"
  else
    redirect "/access"
  end
end 

def create_user(filename,name)
    File.open(filename, "a+") do |file|
    file.puts([name])
    end
end

post "/signup" do
    @newuser = params["newuser"]
    create_user("user.txt",@newuser) 
    redirect "/dashboard/#{params["newuser"]}"
    puts
end

set :port, 8000