require 'sinatra'
require 'icalendar'
require 'date'
require 'json'

# Enable sessions for user authentication
enable :sessions

# Load existing student and parent data
students_data = JSON.parse(File.read('studentParentsData.json')) rescue []

set :port, 4567 # Change the port as needed

# Sample in-memory data store
$calendar_events = []
$lessons_database = []

# Serve the login page as the home page
get '/' do
  erb :login
end

get '/home' do
  erb :home
end

# Serve the calendar page
get '/calendar' do
  erb :calendar
end

# Endpoint to add a new event
post '/calendar' do
  request.body.rewind
  event_data = JSON.parse(request.body.read)
  $calendar_events << event_data
  update_calendar_events_file
  event_data.to_json
end

get '/studentParentsData' do
  erb :studentParentsData
end

# Render the invoices page
get '/invoices' do
  erb :invoices, locals: { students_data: students_data }
end

# Add a route to generate and serve the iCalendar data
get '/calendar.ics' do
  content_type 'text/calendar'

  cal = Icalendar::Calendar.new

  # Add events to the calendar
  $calendar_events.each do |event|
    cal.add_event(create_event(event['title'], event['start_date']))
  end

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

# Handle asynchronous form submission to update invoices
post '/invoices' do
  student_name = params[:student_name]
  parent_email = params[:parent_email]
  parent_phone = params[:parent_phone]
  tuition = params[:tuition]

  # Add new student data
  students_data << {
    student_name: student_name,
    parent_email: parent_email,
    parent_phone: parent_phone,
    tuition: tuition
  }

  # Save the updated data to the file
  File.write('studentParentsData.json', JSON.generate(students_data))

  # Send a response back to the client
  content_type :json
  { success: true, student_name: student_name, parent_email: parent_email, parent_phone: parent_phone, tuition: tuition }.to_json
end

# Handle asynchronous form submission to update student data
post '/update_students' do
  student_name = params[:student_name]
  parent_email = params[:parent_email]
  parent_phone = params[:parent_phone]
  tuition = params[:tuition]

  # Add new student data to the in-memory store
  students_data << {
    student_name: student_name,
    parent_email: parent_email,
    parent_phone: parent_phone,
    tuition: tuition
  }

  # Save the updated data to the file
  File.write('studentParentsData.json', JSON.generate(students_data))

  # Send a response back to the client
  content_type :json
  { success: true, student_name: student_name, parent_email: parent_email, parent_phone: parent_phone, tuition: tuition }.to_json
end

# Endpoint to retrieve all student data
get '/get_students' do
  content_type :json
  students_data.to_json
end


# Run the Sinatra application
run Sinatra::Application
