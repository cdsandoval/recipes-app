require "sinatra"
require "erb"

get "/" do
  erb :index, { :layout => :base }
end

get "/access" do
  erb :access, { :layout => :base }
end

get "/dashboard" do
  erb :dashboard, { :layout => :base }
end

