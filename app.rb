# app.rb
require 'sinatra'
require 'icalendar'
require 'date'

# Existing code...

# Add a route to generate and serve the iCalendar data
get '/calendar.ics' do
  content_type 'text/calendar'

  cal = Icalendar::Calendar.new

  # Add events to the calendar
  cal.add_event(create_event('Divyesh Birthday', '2022-02-21'))
  cal.add_event(create_event('Roshni Birthday', '2022-02-22'))
  cal.add_event(create_event('Shinerweb website renewal', '2022-02-23'))

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
