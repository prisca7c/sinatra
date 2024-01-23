require 'sinatra'
require 'icalendar'
require 'date'
require 'erb'
require 'json'

enable :sessions
set :session_secret, 'super secret'

# Define classes for your data
class Lesson
  attr_accessor :id, :title, :start_date, :student_name

  def initialize(id, title, start_date, student_name)
    @id = id
    @title = title
    @start_date = start_date
    @student_name = student_name
  end
end

class Student
  attr_accessor :id, :name, :contact, :attendance

  def initialize(id, name, contact, attendance)
    @id = id
    @name = name
    @contact = contact
    @attendance = attendance
  end
end

class StudentData
  attr_accessor :student_name, :parent_email, :parent_phone, :tuition, :next_lesson, :makeup_credits

  def initialize(student_name, tuition, parent_name, parent_email, parent_phone, next_lesson, makeup_credits)
    @student_name = student_name
    @tuition = tuition
    @parent_name = parent_name
    @parent_email = parent_email
    @parent_phone = parent_phone
    @next_lesson = next_lesson
    @makeup_credits = makeup_credits
  end
end

# Initialize a single, shared data structure
$data = {
  'lessons' => [],
  'students' => [],
  'studentData' => []
}

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

get '/sinatra/home' do
  erb :invoice
end

#-------------------------CALENDAR---------------------------

post '/calendar' do
  request.body.rewind
  lesson_data = JSON.parse(request.body.read)
  lesson_id = $data['lessons'].length + 1

  lesson = Lesson.new(lesson_id, lesson_data['title'], lesson_data['start_date'], lesson_data['studentName'])
  $data['lessons'] << lesson

  content_type :json
  { success: true, lesson_id: lesson_id }.to_json
end

# Delete lesson by ID
delete '/calendar/:id' do
  lesson_id = params[:id].to_i

  # Find the lesson with the specified ID
  lesson_index = $data['lessons'].index { |lesson| lesson.id == lesson_id }

  if lesson_index
    # Remove the lesson from the array
    deleted_lesson = $data['lessons'].delete_at(lesson_index)

    content_type :json
    { success: true, deleted_lesson: deleted_lesson }.to_json
  else
    content_type :json
    { success: false, message: 'Lesson not found' }.to_json
  end
end

# Get all lessons
get '/get_lessons' do
  content_type :json
  $data['lessons'].to_json
end

#-------------------------INVOICES---------------------------

post '/sinatra/add_invoice' do
  student_name = params[:student_name]
  parent_email = params[:parent_email]
  parent_phone = params[:parent_phone]
  lessons = params[:lessons].to_i
  rate = params[:rate].to_i

  # Calculate tuition
  tuition = lessons * rate

  # Retrieve existing data from local storage or initialize as an empty array
  invoices_data = session[:invoices_data] || '[]'

  # Add the new invoice data
  invoices_data.push({
    student_name: student_name,
    parent_email: parent_email,
    parent_phone: parent_phone,
    lessons: lessons,
    rate: rate,
    tuition: tuition
  })

  # Save the updated data back to the session
  session[:invoices_data] = invoices_data

  redirect '/sinatra/home'
end

get '/sinatra/invoices' do
  # Retrieve data from the session
  invoices_data = session[:invoices_data] || []

  erb :invoices, locals: { invoices_data: invoices_data }
end

# Route to delete an invoice
get '/sinatra/delete_invoice/:index' do |index|
  # Retrieve existing data from the session
  invoices_data = session[:invoices_data] || []

  # Delete the invoice at the specified index
  invoices_data.delete_at(index.to_i)

  # Save the updated data back to the session
  session[:invoices_data] = invoices_data

  # Redirect to the invoices page
  redirect '/sinatra/invoices'
end

#-------------------------ATTENDANCE RECORD---------------------------
# Sample data for students
students = []

# Endpoint to render the attendance page
get '/attendance' do
  erb :index, locals: { students: students }
end

# Endpoint to add a new student
post '/attendance/add_student' do
  request.body.rewind
  data = JSON.parse(request.body.read, symbolize_names: true)

  student_id = data[:id]
  student_name = data[:name]
  contact = data[:contact]
  attendance_status = data[:attendance]

  new_student = Student.new(student_id, student_name, contact, attendance_status)
  $data['students'].push(new_student)

  content_type :json
  { success: true, student: new_student }.to_json
end

# Endpoint to get all students
get '/attendance/get_students' do
  content_type :json
  $data['students'].to_json
end

#-------------------------STUDENT & PARENTS DATA---------------------------

# Serve HTML page
get '/sinatra/studentParentsData' do
  File.read('studentParentsData.html')
end

# Get all students
get '/get_students' do
  $data['studentData'].to_json
end

# Add/update a student
post '/update_students' do
  request.body.rewind
  data = JSON.parse(request.body.read)

  # Validate data (add your validation logic here)

  # Add the student to the list
  student_data = StudentData.new(data['student_name'], data['parent_name'],data['parent_email'], data['parent_phone'], data['next_lesson'], data['makeup_credits'])
  $data['studentData'] << student_data

  { success: true, message: 'Student added successfully' }.to_json
end

# Route to handle sorting
get '/sort_students' do
  sort_by = params[:by]
  students_data = JSON.parse(File.read('students_data.json')) rescue []

  case sort_by
  when 'student_name'
    students_data.sort! { |a, b| a['student_name'] <=> b['student_name'] }
  when 'next_lesson'
    students_data.sort! { |a, b| Date.parse(a['next_lesson']) <=> Date.parse(b['next_lesson']) }
  when 'makeup_credits'
    students_data.sort! { |a, b| b['makeup_credits'].to_i <=> a['makeup_credits'].to_i }
  end

  # Render JSON response
  content_type :json
  students_data.to_json
end

run Sinatra::Application
