require 'sinatra'
require 'icalendar'
require 'date'
require 'json'

enable :sessions

# Example in-memory data structure to store lessons
$lessons = []

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
  lesson_id = $lessons.length + 1

  $lessons << {
    'id' => lesson_id,
    'title' => lesson_data['title'],
    'start_date' => lesson_data['start_date'],
    'student_name' => lesson_data['studentName']
  }

  content_type :json
  { success: true, lesson_id: lesson_id }.to_json
end

post '/studentParentsData' do
  request.body.rewind
  student_data = JSON.parse(request.body.read)
  # Adjusted to use JSON data
  { success: true, data: student_data }.to_json
end

post '/invoices' do
  student_name = params[:student_name]
  parent_email = params[:parent_email]
  parent_phone = params[:parent_phone]
  tuition = params[:tuition]
  # Adjusted to use JSON data
  { success: true, student_name: student_name, parent_email: parent_email, parent_phone: parent_phone, tuition: tuition }.to_json
end

post '/update_students' do
  student_name = params[:student_name]
  parent_email = params[:parent_email]
  parent_phone = params[:parent_phone]
  tuition = params[:tuition]
  # Adjusted to use JSON data
  { success: true, student_name: student_name, parent_email: parent_email, parent_phone: parent_phone, tuition: tuition }.to_json
end

get '/get_students' do
  # Adjusted to use JSON data
  students_data = [{ student_name: 'John Doe', parent_email: 'john@example.com', parent_phone: '123-456-7890', tuition: '100' }]
  content_type :json
  students_data.to_json
end

post '/delete_lesson' do
  request.body.rewind
  lesson_data = JSON.parse(request.body.read)
  lesson_id = lesson_data['lesson_id']

  # Remove the lesson with the given ID from the lessons array
  $lessons.reject! { |lesson| lesson['id'] == lesson_id }

  content_type :json
  { success: true }.to_json
end

run Sinatra::Application
