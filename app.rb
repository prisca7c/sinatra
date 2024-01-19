require 'sinatra'
require 'icalendar'
require 'date'
require 'json'
require 'sqlite3'

enable :sessions

# Open a database
$db = SQLite3::Database.new "test.db"

# Create tables
$db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS students (
    id INTEGER PRIMARY KEY,
    student_name TEXT,
    parent_email TEXT,
    parent_phone TEXT,
    tuition TEXT
  );
SQL

$db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS lessons (
    id INTEGER PRIMARY KEY,
    title TEXT,
    start_date TEXT
  );
SQL

set :port, 4567

get '/' do
  erb :login
end

get '/home' do
  erb :home
end

get '/calendar' do
  erb :calendar
end

post '/calendar' do
  request.body.rewind
  lesson_data = JSON.parse(request.body.read)
  $db.execute("INSERT INTO lessons (title, start_date) VALUES (?, ?)", [lesson_data['lesson_type'], lesson_data['date']])
  content_type :json
  { success: true }.to_json
end

get '/studentParentsData' do
  erb :studentParentsData
end

get '/invoices' do
  students_data = $db.execute("SELECT * FROM students")
  erb :invoices, locals: { students_data: students_data }
end

get '/calendar.ics' do
  content_type 'text/calendar'
  cal = Icalendar::Calendar.new
  $db.execute("SELECT * FROM lessons") do |row|
    cal.add_event(create_event(row[1], row[2]))
  end
  cal.to_ical
end

def create_event(title, start_date)
  event = Icalendar::Event.new
  event.summary = title
  event.dtstart = DateTime.parse(start_date)
  event
end

post '/add_student' do
  redirect '/' unless session[:user]
  date = params[:date]
  student_name = params[:student_name]
  puts "Adding student '#{student_name}' to date '#{date}'"
  content_type :json
  { success: true }.to_json
end

post '/studentParentsData' do
  request.body.rewind
  student_data = JSON.parse(request.body.read)
  $db.execute("INSERT INTO students (student_name, parent_email, parent_phone, tuition) VALUES (?, ?, ?, ?)", [student_data['student_name'], student_data['parent_email'], student_data['parent_phone'], student_data['tuition']])
  student_data.to_json
end


post '/invoices' do
  student_name = params[:student_name]
  parent_email = params[:parent_email]
  parent_phone = params[:parent_phone]
  tuition = params[:tuition]
  $db.execute("INSERT INTO students (student_name, parent_email, parent_phone, tuition) VALUES (?, ?, ?, ?)", [student_name, parent_email, parent_phone, tuition])
  content_type :json
  { success: true, student_name: student_name, parent_email: parent_email, parent_phone: parent_phone, tuition: tuition }.to_json
end

post '/update_students' do
  student_name = params[:student_name]
  parent_email = params[:parent_email]
  parent_phone = params[:parent_phone]
  tuition = params[:tuition]
  $db.execute("UPDATE students SET parent_email = ?, parent_phone = ?, tuition = ? WHERE student_name = ?", [parent_email, parent_phone, tuition, student_name])
  content_type :json
  { success: true, student_name: student_name, parent_email: parent_email, parent_phone: parent_phone, tuition: tuition }.to_json
end

get '/get_students' do
  students_data = $db.execute("SELECT * FROM students")
  content_type :json
  students_data.to_json
end

post '/delete_lesson' do
  request.body.rewind
  lesson_data = JSON.parse(request.body.read)
  $db.execute("DELETE FROM lessons WHERE id = ?", [lesson_data['lesson_id']])
  content_type :json
  { success: true }.to_json
end




run Sinatra::Application
