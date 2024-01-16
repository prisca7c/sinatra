# app.rb
require 'sinatra'
require 'sinatra/reloader' if development?

enable :sessions

get '/' do
  erb :home, locals: { username: session[:username] }
end

get '/login' do
  erb :login
end

post '/login' do
  username = params[:username]
  password = params[:password]

  # Simulated authentication logic (replace with proper authentication)
  if username == 'user' && password == 'password'
    session[:user_authenticated] = true
    session[:username] = username
    redirect '/'
  else
    erb :login, locals: { error: 'Invalid username or password' }
  end
end

get '/logout' do
  session[:user_authenticated] = false
  redirect '/'
end
