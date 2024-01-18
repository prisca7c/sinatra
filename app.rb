require 'sinatra'
require 'icalendar'
require 'date'
require 'sinatra/activerecord'
require 'bcrypt'
  
# Enable sessions for user authentication
enable :sessions

# Set up SQLite database
set :database, { adapter: 'sqlite3', database: 'users.db' }

# Define a User model
class User < ActiveRecord::Base
  validates_presence_of :username, :password
end

# Serve the login page as the home page
get '/' do
  erb :login
end

get '/register' do
  erb :register
end

# Handle user registration
post '/register' do
  username = params[:username]
  password = params[:password]

  # Hash the password before saving to the database
  hashed_password = BCrypt::Password.create(password)

  user = User.create(username: username, password: hashed_password)

  redirect '/'
end

get '/home' do
  erb :home
end

# Serve the calendar page
get '/calendar' do
  # Check if the user is authenticated
  redirect '/' unless session[:user]

  erb :calendar
end

# Login form submission
post '/' do
  username = params[:username]
  password = params[:password]

  user = User.find_by(username: username)

  if user && BCrypt::Password.new(user.password) == password
    session[:user] = user.id
    redirect '/calendar'
  else
    redirect '/'
  end
end

# Logout route
get '/logout' do
  session.clear
  redirect '/'
end

get '/student-parents-data' do
  # Check if the user is authenticated
  redirect '/' unless session[:user]

  erb :studentParentsData
end

get '/invoices' do
  # Check if the user is authenticated
  redirect '/' unless session[:user]

  erb :invoices
end

# Add a route to generate and serve the iCalendar data
get '/calendar.ics' do
  content_type 'text/calendar'

  cal = Icalendar::Calendar.new

  # Add events to the calendar
  cal.add_event(create_event('I made this', '2024-01-16'))
  cal.add_event(create_event('New Years Day', '2024-01-01'))
  cal.add_event(create_event('prisca birthday', '2024-08-12'))

  cal.to_ical
end

# Helper method to create an iCalendar event
def create_event(title, start_date)
  event = Icalendar::Event.new
  event.summary = title
  event.dtstart = DateTime.parse(start_date)
  event
end

# Add a route to handle adding a student to a specific day
post '/add_student' do
  # Check if the user is authenticated
  redirect '/' unless session[:user]

  date = params[:date]
  student_name = params[:student_name]

  # Perform logic to add the student to the specified date
  # For now, we'll just print the information to the console
  puts "Adding student '#{student_name}' to date '#{date}'"

  # Return a JSON response
  content_type :json
  { success: true }.to_json
end


# Run the Sinatra application
run Sinatra::Application
