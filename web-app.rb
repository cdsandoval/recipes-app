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

get "/recipe/:difficult" do
  list_recipe = JSON.parse(  File.read("model/recipes.json"))
  @recipes = list_recipe.select {|recipe| recipe["difficult"] == params["difficult"]}
  erb :recipe, { :layout => :base }
end

post "/recipe-difficulty" do
  var = JSON.parse(  File.read("model/recipes.json"))
  var = var.map {|recipe|
    if recipe["id"] == params["id"].to_i
      recipe["difficult"] = params["difficulty"]
    end
    recipe
  }

  var = JSON.generate(var)
  File.write("model/recipes.json", var)
  redirect "/recipe"
end

post "/recipe-quality" do
  var = JSON.parse(  File.read("model/recipes.json"))
  var = var.map {|recipe|
    if recipe["id"] == params["id"].to_i
      recipe["quality"] = params["quality"].to_i
    end
    recipe
  }

  var = JSON.generate(var)
  File.write("model/recipes.json", var)
  redirect "/recipe"
end



set :port, 8000