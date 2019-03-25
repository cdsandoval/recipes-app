require "sinatra"
require "erb"
require "sinatra/reloader"
require "json"

get "/" do
  @recipes = JSON.parse(File.read("model/recipes.json"))
  prom_rankings_recipes(@recipes)
  erb :index, { :layout => :base }
end

get "/sort/:data" do
  @word = params[:name]
  @users = JSON.parse(File.read("model/users.json"))
  @search_list = JSON.parse(File.read("model/recipes.json"))  
   
  if params[:sort] == "difficulty"
    levels = ["Easy","Medium","Hard"]   
    @recipes = @search_list.sort_by { |k,v| levels.index(v["difficult_display"]) }  
    @recipes = prom_rankings_recipes(@recipes)
  elsif params[:sort] == "quality"
    @recipes = @search_list.sort_by { |k, v| v["quality"].join.to_i }
    prom_rankings_recipes(@recipes)
  elsif params[:difficult]
    @recipes = @search_list.select { |k,v| v["difficult_display"] == params[:difficult]}
    prom_rankings_recipes(@recipes)
  elsif params[:quality]
    @recipes = @search_list.select { |k,v| v["quality"].join.to_i == params[:quality].to_i }
    prom_rankings_recipes(@recipes)
  elsif @word.include?("search")
    @recipes = @search_list
    prom_rankings_recipes(@recipes)
  else
    @recipes = read_recipes("model/recipes.json")
    prom_rankings_recipes(@recipes)
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
  @search_list = JSON.parse(File.read("model/search.json"))  
   
  
  if params[:sort] == "difficulty"
      @recipes = @search_list.each { |k, v| 
        v["difficult_display"] == "Easy" ? 
        v["difficult_display"] = 1 :  
        v["difficult_display"] == "Medium" ?
        v["difficult_display"] = 2 :
        v["difficult_display"] = 3
      }
      @recipes = @recipes.sort_by { |k,v| v["difficult_display"].to_i }
      @recipes = @recipes.each { |k,v| 
        v["difficult_display"] == 1 ? 
        v["difficult_display"] = "Easy" :  
        v["difficult_display"] == 2 ?
        v["difficult_display"] = "Medium" :
        v["difficult_display"] = "Hard"
      }
     
  elsif params[:sort] == "quality"
    @recipes = @search_list.sort_by { |k, v| v["quality"].join.to_i }.reverse 
  elsif params[:difficult]
    @recipes = @search_list.select { |k,v| v["difficult_display"] == params[:difficult]}
  elsif params[:quality]
    @recipes = @search_list.select { |k,v| v["quality"].join.to_i == params[:quality].to_i }
  elsif @word.include?("search")
    @recipes = @search_list
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

get %r"/add-recipe/step2" do
  erb :add_recipe_step2, { :layout => :base }
end

get "/add-recipe/:id_user" do
  @id_user = params["id_user"]
  erb :add_recipe, { :layout => :base}
end

post "/add-recipe" do
  id_user = params["id_user"]
  name = params["name"][0..79].gsub(" ", "_")
  difficult = params["difficult"]
  qualitly = params["qualitly"]
  duration_time = params["duration_time"]
  steps = params["steps"]
  redirect "/add-recipe/step2?id_user=#{id_user}&name=#{name}&difficult=#{difficult}&qualitly=#{qualitly}&duration_time=#{duration_time}&steps=#{steps}"
end

post "/add-recipe/step2" do
  save_image(params["image"].values)
  new_id = Time.now.getutc.to_i
  # Save new recipe
  json_recipes = JSON.parse(File.read("model/recipes.json"))
  json_recipes[new_id] = {
    "id"=> new_id,
    "name" => params["name"].gsub("_", " "),
    "difficult" => [params["difficult"].to_i],
    "duration_time" => [params["duration_time"].to_i],
    "quality" => [params["qualitly"].to_i],
    "difficult_display" => define_display_difficulty(params["difficult"].to_i),
    "images" => params["image"].values.map { |fileimage| "/images/#{fileimage[:filename]}"},
    "preparation" => params["preparation"].values
  }
  File.write("model/recipes.json", JSON.generate(json_recipes))
  # Set recipe in user
  json_users = JSON.parse(File.read("model/users.json"))
  json_users[params["id_user"]]["recipes"] << new_id
  File.write("model/users.json", JSON.generate(json_users))
  redirect "/recipes/#{new_id}"
end

def save_image(arr_file_images)
  arr_file_images.each do |file_image|
    filename = file_image[:filename]
    file = file_image[:tempfile]
    File.open("./public/images/#{filename}", 'wb') do |f|
      f.write(file.read)
    end
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
  File.write("model/users.json", JSON.generate(json_users))
end

post "/search" do
  $recipe_title = params["recipe_title"].downcase
  @name = params["name"]
  @recipe_list = read_recipes("model/recipes.json")
  @recipes = @recipe_list.select {|key,value| value["name"].downcase.include?($recipe_title)}
  create_search("model/search.json",@recipes)
  redirect "/dashboard/recipes/search?#{$recipe_title}"
end

post "/recipe-difficulty" do
  id_recipe = params["id"]
  var = read_recipes("model/recipes.json")
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
  var = read_recipes("model/recipes.json")
  var[id_recipe]["quality"] << params["quality"].to_i
  var[id_recipe]["quality"] = [prom(var[id_recipe]["quality"])]
  var = JSON.generate(var)
  File.write("model/recipes.json", var)
  redirect "/recipes/#{id_recipe}"
end

post "/recipe-duration-time" do
  id_recipe = params["id"]
  var = read_recipes("model/recipes.json")
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

def prom_rankings_recipes(recipes)
  recipes = recipes.each do |key, recipe|
    recipe["quality"] = prom(recipe["quality"]).to_i
    recipe["duration_time"] = prom(recipe["duration_time"])
    recipe["difficult"] = prom(recipe["difficult"]).to_i
    recipe
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

set :port, 8000


post "/sort" do
  @sort_type = params["sort_type"]
  @quality = params["quality_filter"]
  @difficult = params["difficult_filter"]
  if @quality    
    redirect "dashboard/recipes/search?quality=#{@quality}"
  elsif @difficult
    redirect "dashboard/recipes/search?difficult=#{@difficult}"
  else
    redirect "/dashboard/recipes/search?sort=#{@sort_type}"
  end
end

post "/sort_index" do
  @sort_type = params["sort_type"]
  @quality = params["quality_filter"]
  @difficult = params["difficult_filter"]
  if @quality    
    redirect "/sort/search?quality=#{@quality}"
  elsif @difficult
    redirect "/sort/search?difficult=#{@difficult}"
  else
    redirect "/sort/search?sort=#{@sort_type}"
  end
end
