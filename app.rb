require 'sinatra'
require 'icalendar'
require 'date'
require 'erb'
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

# Assuming $lessons is an array holding your lessons

# Delete lesson by ID
delete '/calendar/:id' do
  lesson_id = params[:id].to_i

  # Find the lesson with the specified ID
  lesson_index = $lessons.index { |lesson| lesson['id'] == lesson_id }

  if lesson_index
    # Remove the lesson from the array
    deleted_lesson = $lessons.delete_at(lesson_index)

    content_type :json
    { success: true, deleted_lesson: deleted_lesson }.to_json
  else
    content_type :json
    { success: false, message: 'Lesson not found' }.to_json
  end
end


#-------------------------ATTENDANCE RECORD---------------------------
# Sample data for students
students = [
  { id: 1, name: 'John Doe', attendance: false },
  { id: 2, name: 'Jane Doe', attendance: false },
  # Add more students as needed
]

get '/attendance' do
  erb :index, locals: { students: students }
end

post '/attendance/update_attendance' do
  request.body.rewind
  data = JSON.parse(request.body.read, symbolize_names: true)

  student_id = data[:student_id]
  attendance_status = data[:attendance_status]

  student = students.find { |s| s[:id] == student_id }
  student[:attendance] = attendance_status

  content_type :json
  { success: true }.to_json
end

post '/attendance/add_student' do
  request.body.rewind
  data = JSON.parse(request.body.read, symbolize_names: true)

  student_id = data[:id]
  student_name = data[:name]
  attendance_status = data[:attendance]

  new_student = { id: student_id, name: student_name, attendance: attendance_status }
  students.push(new_student)

  content_type :json
  { success: true, student: new_student }.to_json
end

post '/attendance/delete_student' do
  request.body.rewind
  data = JSON.parse(request.body.read, symbolize_names: true)

  student_id = data[:id]

  students.reject! { |student| student[:id] == student_id }

  content_type :json
  { success: true }.to_json
end

get '/attendance/get_students' do
  content_type :json
  students.to_json
end
run Sinatra::Application
