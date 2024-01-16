# app.rb
require 'sinatra'
require 'sinatra/reloader' if development?

# Sample data for students and parents info
$students = [
  { id: 1, name: 'John Doe', instrument: 'Piano', parent: 'Jane Doe' },
  { id: 2, name: 'Alice Smith', instrument: 'Guitar', parent: 'Bob Smith' },
  { id: 3, name: 'Charlie Brown', instrument: 'Violin', parent: 'Lucy Brown' }
]

# Sample data for calendar events
$calendar_events = [
  { id: 1, title: 'Recital', date: '2024-05-15', location: 'Concert Hall' },
  { id: 2, title: 'Lesson - John Doe', date: '2024-05-20', location: 'Studio 1' },
  { id: 3, title: 'Practice Session', date: '2024-05-25', location: 'Practice Room' }
]

# Sample data for invoices
$invoices = [
  { id: 1, student_id: 1, amount: 100, due_date: '2024-06-01' },
  { id: 2, student_id: 2, amount: 80, due_date: '2024-06-10' },
  { id: 3, student_id: 3, amount: 120, due_date: '2024-06-15' }
]

# Sample data for attendance records
$attendance_records = [
  { id: 1, student_id: 1, date: '2024-05-20', status: 'Present' },
  { id: 2, student_id: 2, date: '2024-05-22', status: 'Absent' },
  { id: 3, student_id: 3, date: '2024-05-25', status: 'Present' }
]

enable :sessions

# Login page
get '/login' do
  erb :login
end

# Main page with four boxes
get '/main' do
  redirect '/login' unless session[:user_authenticated]

  erb :main
end

# Logout
get '/logout' do
  session[:user_authenticated] = false
  redirect '/login'
end

# Validate login credentials
post '/authenticate' do
  username = params[:username]
  password = params[:password]

  # Add your authentication logic here
  # For simplicity, let's use a hardcoded username and password
  if username == 'admin' && password == 'password'
    session[:user_authenticated] = true
    redirect '/main'
  else
    erb :login, locals: { error: 'Invalid username or password' }
  end
end
