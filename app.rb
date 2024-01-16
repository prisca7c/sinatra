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

# Layout for the HTML views
__END__

@@layout
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Music School App</title>
</head>
<body>
  <%= yield %>
</body>
</html>

@@login
<h1>Login</h1>
<% if defined?(error) %>
  <p style="color: red;"><%= error %></p>
<% end %>
<form action="/authenticate" method="post">
  <label for="username">Username:</label>
  <input type="text" id="username" name="username" required><br>

  <label for="password">Password:</label>
  <input type="password" id="password" name="password" required><br>

  <button type="submit">Login</button>
</form>

@@main
<h1>Welcome to the Music School App</h1>

<div style="display: flex; justify-content: space-around; margin-top: 20px;">
  <div style="border: 1px solid #ddd; padding: 10px; width: 200px;">
    <h2>Students and Parents Info</h2>
    <ul>
      <% $students.each do |student| %>
        <li><%= student[:name] %> - <%= student[:instrument] %> (Parent: <%= student[:parent] %>)</li>
      <% end %>
    </ul>
  </div>

  <div style="border: 1px solid #ddd; padding: 10px; width: 200px;">
    <h2>Calendar</h2>
    <ul>
      <% $calendar_events.each do |event| %>
        <li><%= event[:title] %> - <%= event[:date] %> at <%= event[:location] %></li>
      <% end %>
    </ul>
  </div>

  <div style="border: 1px solid #ddd; padding: 10px; width: 200px;">
    <h2>Invoices</h2>
    <ul>
      <% $invoices.each do |invoice| %>
        <li>Invoice <%= invoice[:id] %> - Amount: $<%= invoice[:amount] %> (Due: <%= invoice[:due_date] %>)</li>
      <% end %>
    </ul>
  </div>

  <div style="border: 1px solid #ddd; padding: 10px; width: 200px;">
    <h2>Attendance Record</h2>
    <ul>
      <% $attendance_records.each do |record| %>
        <li><%= $students.find { |s| s[:id] == record[:student_id] }[:name] %> - <%= record[:status] %> on <%= record[:date] %></li>
      <% end %>
    </ul>
  </div>
</div>

<a href="/logout">Logout</a>
