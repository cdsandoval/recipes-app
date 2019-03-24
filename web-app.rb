require "sinatra"
require "erb"
require "sinatra/reloader"
require "json"

get "/" do
  @recipes = JSON.parse(File.read("model/recipes.json"))
  @recipes = @recipes.each do |key, recipe|
    recipe["quality"] = prom(recipe["quality"]).to_i
    recipe["duration_time"] = prom(recipe["duration_time"])
    recipe["difficult"] = prom(recipe["difficult"]).to_i
    recipe
  end
  erb :index, { :layout => :base }
end

get "/access" do
  erb :access, { :layout => :base }
end

get "/dashboard/:id_user" do
  @id_user = params["id_user"]
  @users = JSON.parse(File.read("model/users.json"))
  @name_user = @users[@id_user]["name"]
  if @id_user.include?("search")
    @recipes = JSON.parse()
  else
    @recipes = JSON.parse(File.read("model/recipes.json"))
    if @name_user == "admin"
      recipes_all = []
      @recipes.each { |key, recipe| recipes_all << @recipes[key] }
      @recipes = recipes_all
    else
      @recipes = @users[@id_user]["recipes"].map do |id_recipe|
        @recipes[id_recipe.to_s]
      end
    end
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

get "/recipes/:id_recipe" do
  id_recipe = params["id_recipe"]
  file = File.read("model/recipes.json")
  @recipe = JSON.parse(file)[id_recipe.to_s]
  erb :recipe, { :layout => :base }
end

get "/add-recipe/:id_user" do
  @id_user = params["id_user"]
  erb :add_recipe, { :layout => :base}
end

post "/add-recipe" do
  save_image(params)
  new_id = Time.now.getutc.to_i
  json_recipes = JSON.parse(File.read("model/recipes.json"))
  json_recipes[new_id] = {
    "id"=> new_id,
    "name" => params["name"][0..79],
    "difficult" => [params["difficult"].to_i],
    "duration_time" => [params["duration_time"].to_i],
    "url_image" => "/images/#{params[:file][:filename]}",
    "preparation" => params["preparation"],
    "quality" => [params["qualitly"].to_i],
    "difficult_display" => define_display_difficulty(params["difficult"].to_i)
  }
  File.write("model/recipes.json", JSON.generate(json_recipes))

  json_users = JSON.parse(File.read("model/users.json"))
  json_users[params["id_user"]]["recipes"] << new_id
  File.write("model/users.json", JSON.generate(json_users))

  redirect "/recipes/#{new_id}"
end

def save_image(params)
  @filename = params[:file][:filename]
  file = params[:file][:tempfile]
  File.open("./public/images/#{@filename}", 'wb') do |f|
    f.write(file.read)
  end
end

get "/recipe/:difficult" do
  list_recipe = read_recipes("model/recipes.json")
  @recipes = list_recipe.select {|recipe| recipe["difficult"] == params["difficult"]}
  erb :recipe, { :layout => :base }
end

#############################POST#############################

post "/access" do
  name = params["name"]
  id_user = authentic(name)
  if id_user
    redirect "/dashboard/#{id_user}"
  else
    redirect "/access"
  end
end

post "/signup" do
  @newuser = params["newuser"].downcase
  @users = JSON.parse(File.read("model/users.json"))
  @new_id = Time.now.getutc.to_i
  @users[@new_id] = {"id"=> @new_id,
    "name" => @newuser,
    "recipes" => []
  }
  File.write("model/users.json", JSON.generate(@users))
  redirect "/dashboard/#{@new_id }"
end

post "/delete-recipe" do
  @id_recipe = params["id_recipe"]
  @name = params["name"]
  @id_user = params["id_user"]
  delete_recipe("model/recipes.json", @id_recipe)
  delete_recipe("model/search.json", @id_recipe)
  delete_recipe_user(@id_user, @id_recipe)
  redirect "/dashboard/#{@id_user}"
end

def delete_recipe_user(id_user, id_recipe)
  json_users = JSON.parse(File.read("model/users.json"))
  json_users[id_user.to_s]["recipes"].delete(id_recipe.to_i)
  puts "AAAAAAAAAAAAAAAAAAAAAH"
  puts json_users[id_user.to_s]["recipes"].inspect
  puts "AAAAAAAAAAAAAAAAAAAAAH"

  File.write("model/users.json", JSON.generate(json_users))
end

post "/search" do
  @recipe_title = params["recipe_title"].downcase
  @name = params["name"]
  @recipe_list = read_recipes("model/recipes.json")
  @recipes = @recipe_list.select {|key,value| value["name"].downcase.include?(@recipe_title)}
  create_search("model/search.json",@recipes)
  redirect "/dashboard/recipes/search?#{@recipe_title}"
end

post "/recipe-difficulty" do
  id_recipe = params["id"]
  var = JSON.parse(File.read("model/recipes.json"))
  var[id_recipe]["difficult"] << params["difficulty"].to_i
  var[id_recipe]["difficult_display"] = define_display_difficulty(var[id_recipe]["difficult"].reduce(:+)/var[id_recipe]["difficult"].size.to_f)
  var = JSON.generate(var)
  File.write("model/recipes.json", var)
  redirect "/recipes/#{id_recipe}"
end


def define_display_difficulty(n)
  if n <= 1.5
    return "Easy"
  elsif n <= 2.5
    return "Medium"
  else
    return "Hard"
  end
end

post "/recipe-quality" do
  id_recipe = params["id"]
  var = JSON.parse(File.read("model/recipes.json"))
  var[id_recipe]["quality"] << params["quality"].to_i
  var[id_recipe]["quality"] = [prom(var[id_recipe]["quality"])]
  var = JSON.generate(var)
  File.write("model/recipes.json", var)
  redirect "/recipes/#{id_recipe}"
end

post "/recipe-duration-time" do
  id_recipe = params["id"]
  var = JSON.parse(  File.read("model/recipes.json"))
  var[id_recipe]["duration_time"] << params["duration-time"].to_i
  var[id_recipe]["duration_time"] = [prom(var[id_recipe]["duration_time"])]
  var = JSON.generate(var)
  File.write("model/recipes.json", var)
  redirect "/recipes/#{id_recipe}"
end

######################### METHODS #########################

def create_user(filename,name)
  File.open(filename, "a+") do |file|
  file.puts([name])
  end
end

def read_recipes(filename)
  JSON.parse(File.read(filename))
end

def delete_recipe(filename, id)
  @recipe_list = read_recipes("model/recipes.json")
  @recipe_list.delete(id)
  create_search(filename,@recipe_list)
end

def create_search(filename,name)
  File.open(filename, "w+") do |file|
  file.puts(name.to_json)
  end
end

def store_name(filename, string)
  File.open(filename, "a+") do |file|
    file.puts([string])
  end
end

def authentic(username)
  # Return id of the username or false if the username don't exist
  user = read_recipes("model/users.json")
  username_match = user.select { |key, hash| hash["name"] == username }
  if username_match.count > 0
    return username_match.first[1]["id"]
  end
  false
end

def prom(numbers)
  numbers.reduce(0) {|n1,n2| n1 + n2}/numbers.count
end

set :port, 8033
