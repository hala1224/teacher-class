# require './config/environment'

# class ApplicationController < Sinatra::Base

#   configure do
#     set :public_folder, 'public'
#     set :views, 'app/views'
#   end

#   get "/" do
#     erb :welcome
#   end

# end

require './config/environment'
require 'rack-flash'

class ApplicationController < Sinatra::Base
   use Rack::Flash

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "password_security"
  end

  get "/" do
    if logged_in?
      redirect '/categories'
    else
      erb :index
    end
  end

  get "/login" do
    if logged_in?
      redirect '/categories'
    else
      erb :"/teachers/login"
    end
  end

  get "/signup" do
    if logged_in?
      flash[:notice] = "You're already logged in! Redirecting..."
      redirect '/categories'
    else
      erb :"/teachers/create_teacher"
    end
  end

  post "/signup" do
    if params[:name] == "" || params[:password] == "" || params[:email] == ""
      flash[:error] = "You have missing required fields."
      redirect '/signup'
    else

      @teacher = Teacher.new(params)
      @teacher.save
      session[:teacher_id] = @teacher.id
      flash[:notice] = "Welcome to Community Gym"
      redirect '/categories'
    end
  end


  post "/login" do
     # binding.pry
    @teacher = Teacher.find_by(:name => params[:name])
    if @teacher && @teacher.authenticate(params[:password])
      session[:teacher_id] = @teacher.id
      flash[:success] = "Welcome, #{@teacher.name}!"
      redirect '/categories'
    else
      flash[:error] = "Login failed!"
      redirect '/login'
    end
  end

  get '/teachers/:slug' do
    @teacher = Teacher.find_by_slug(params[:slug])
    @categories = @teacher.categories
    erb :"/teachers/show"
  end


  get "/categories/new" do
    @teacher = current_teacher
    if logged_in?
      erb :"/categories/create_category"
    else
      redirect '/login'
    end
  end

  post "/new" do
    if logged_in? && params[:content] != ""
      @teacher = current_teacher
      @category = Category.create(content: params["content"], teacher_id: params[:teacher_id])
      @category.save
      erb :"/categories/show_category"
    elsif logged_in? && params[:content] == ""
      flash[:notice] = "Your class is blank!"
      redirect '/categories/new'
    else
      flash[:notice] = "Please log in to proceed"
      redirect '/login'
    end
  end

  get "/categories" do
    if logged_in?
      @teacher = current_teacher
      erb :"/categories/categories"
    else
      redirect '/login'
    end
  end

  get "/categories/:id" do
    @teacher = current_teacher
    @category = Category.find_by_id(params[:id])
    if !logged_in?
      redirect '/login'
    else
      erb :"/categories/show_category"
    end
  end

  get "/categories/:id/edit" do
    if logged_in?
      @category = Category.find(params[:id])
      if @category.teacher_id == session[:teacher_id]
        # binding.pry
      erb :"/categories/edit_category"
      else
        redirect '/login'
      end
    else
      redirect '/login'
    end
  end

    patch "/categories/:id" do
      if params[:content] == ""
        flash[:notice] = "Please enter content to proceed"
        redirect "/categories/#{params[:id]}/edit"
      else
        @category = Category.find(params[:id])
        @category.update(content: params[:content])
        redirect "/categories/#{@category.id}"
      end
    end

    delete "/categories/:id/delete" do
      @teacher = current_teacher
      # binding.pry
      puts "#{@teacher}"
      @category = Category.find_by_id(params[:id])
      if logged_in? && @category.teacher_id == session[:teacher_id]
        @category.delete
        erb :'/categories/delete'
      elsif !logged_in? || @category.teacher_id != session[:teacher_id]
        erb :'/categories/error'
      else
        erb :'/categories/error'
      end
    end


    get "/logout" do
      if logged_in?
        session.clear
        redirect '/login'
      else
        session.clear
        redirect '/'
      end
    end





helpers do
    def current_teacher
      @current_teacher ||= Teacher.find(session[:teacher_id]) if session[:teacher_id]
    end

    def logged_in?
      !!current_teacher
    end
  end
end
