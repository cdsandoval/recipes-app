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
  @recipes = JSON.parse(  File.read("model/recipes.json"))  
  @recipes = @recipes.each do |key, recipe|
    recipe["quality"] = prom(recipe["quality"]).to_i
    recipe["duration_time"] = prom(recipe["duration_time"])
    recipe["difficult"] = prom(recipe["difficult"]).to_i
    recipe
  end
  erb :recipe, { :layout => :base }
end

def prom(numbers)
  numbers.reduce(0) {|n1,n2| n1 + n2}/numbers.count 
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
    @newuser = params["newuser"].downcase! 
    create_user("user.txt",@newuser) 
    redirect "/dashboard/#{params["newuser"]}"
    puts
end

def prom(numbers)
  numbers.reduce(0) {|n1,n2| n1 + n2}/numbers.count 
end

get "/recipe/:difficult" do
  list_recipe = JSON.parse(  File.read("model/recipes.json"))
  @recipes = list_recipe.select {|recipe| recipe["difficult"] == params["difficult"]}
  erb :recipe, { :layout => :base }
end

post "/recipe-difficulty" do
  var = JSON.parse(  File.read("model/recipes.json"))
  var[params["id"]]["difficult"] << params["difficulty"].to_i
  var = JSON.generate(var)
  File.write("model/recipes.json", var)
  redirect "/recipe"
end

post "/recipe-qualitly" do
  var = JSON.parse(  File.read("model/recipes.json"))
  var[params["id"]]["quality"] << params["qualitly"].to_i
  var = JSON.generate(var)
  File.write("model/recipes.json", var)
  redirect "/recipe"
end

post "/recipe-duration-time" do
  var = JSON.parse(  File.read("model/recipes.json"))
  var[params["id"]]["duration_time"] << params["duration-time"].to_i
  
  var = JSON.generate(var)
  File.write("model/recipes.json", var)
  redirect "/recipe"
end

post '/save_image' do
  @filename = params[:file][:filename]
  file = params[:file][:tempfile]
  File.open("./public/images/#{@filename}", 'wb') do |f|
    f.write(file.read)
  end

  erb :recipe
end

set :port, 8000