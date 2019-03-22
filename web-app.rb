require "sinatra"
require "erb"
require "sinatra/reloader"
require "json"


get "/" do
  erb :index, { :layout => :base }
end

get "/access" do
 erb :access, { :layout => :base }
end

get "/dashboard/:name" do
  @word = params[:name]
  @users = JSON.parse(File.read("model/users.json"))   
  if @word.include?("search")  
    @recipes = JSON.parse(File.read("model/search.json"))
  else
    @recipes = JSON.parse(File.read("model/recipes.json"))    
  end
  erb :dashboard, { :layout => :base }
end

get "/dashboard/recipes/:name" do
  @word = params[:name]
  @users = JSON.parse(File.read("model/users.json"))   
  if @word.include?("search")  
    @recipes = JSON.parse(File.read("model/search.json"))
  else
    @recipes = JSON.parse(File.read("model/recipes.json"))    
  end
  erb :search, { :layout => :base }
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

get "/add-recipe" do
  erb :add_recipe, { :layout => :base }
end

get "/recipe/:difficult" do
  list_recipe = JSON.parse(  File.read("model/recipes.json"))
  @recipes = list_recipe.select {|recipe| recipe["difficult"] == params["difficult"]}
  erb :recipe, { :layout => :base }
end

##########################################################################
#############################POST#########################################
##########################################################################


post "/access" do
  @name = params["name"]
  # store_name("user.txt", @name)
  if authentic(@name)
    redirect "/dashboard/#{@name}"
  else
    redirect "/access"
  end
end

post "/signup" do
    @newuser = params["newuser"].downcase! 
    create_user("user.txt",@newuser) 
    redirect "/dashboard/#{params["newuser"]}"    
end

post "/recipe-difficulty" do
  var = JSON.parse(File.read("model/recipes.json"))
  var[params["id"]]["difficult"] << params["difficulty"].to_i
  var = JSON.generate(var)
  File.write("model/recipes.json", var)
  redirect "/recipe"
end

post "/recipe-qualitly" do
  var = JSON.parse(  File.read("model/recidef prom(numbers)
  numbers.reduce(0) {|n1,n2| n1 + n2}/numbers.count 
endpes.json"))
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

post "/delete-recipe" do
  @recipe_id = params["id"]
  @name = params["name"]
  delete_recipe("model/recipes.json",@recipe_id)  
  delete_recipe("model/search.json",@recipe_id)  
  redirect "/dashboard/search?#{@name}"
end

post "/search" do
  @recipe_title = params["recipe_title"].downcase
  @name = params["name"]  
  @recipe_list = read_db()  
  @recipes = @recipe_list.select {|key,value| value["name"].downcase.include?(@recipe_title)}
  create_search("model/search.json",@recipes)
  redirect "/dashboard/recipes/search?#{@name}?#{@recipe_title}"
end

#############################################################
#########################METHODS############################
############################################################

def create_user(filename,name)
  File.open(filename, "a+") do |file|
  file.puts([name])
  end
end

def delete_recipe(filename,id)
  @recipe_list = read_db()
  @recipe_list.delete(id)
  create_search(filename,@recipe_list)
end

def create_search(filename,name)
File.open(filename, "w+") do |file|
file.puts(name.to_json)
end
end

def prom(numbers)
  numbers.reduce(0) {|n1,n2| n1 + n2}/numbers.count 
end

def store_name(filename, string)
  File.open(filename, "a+") do |file|
    file.puts([string])
  end
end

def read_db()
  JSON.parse(  File.read("model/recipes.json"))  
end

def authentic(username)
  user = JSON.parse( File.read("model/users.json"))  
  @our_user = user.map do |key,value|
    if value["name"] == username
      true
    else
      false
    end    
  end
  @our_user.include? true  
end


def prom(numbers)
  numbers.reduce(0) {|n1,n2| n1 + n2}/numbers.count 
end

set :port, 8000