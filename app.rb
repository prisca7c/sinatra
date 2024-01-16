# app.rb
require 'sinatra'
require 'json'

class Teacher
  attr_accessor :id, :name, :subject

  def initialize(id, name, subject)
    @id = id
    @name = name
    @subject = subject
  end
end

class TeacherManager
  attr_reader :teachers

  def initialize
    @teachers = []
  end

  def add_teacher(name, subject)
    id = @teachers.length + 1
    teacher = Teacher.new(id, name, subject)
    @teachers << teacher
  end

  def sort_teachers_by_name
    @teachers.sort_by!(&:name)
  end

  def to_json
    { teachers: @teachers.map { |teacher| { id: teacher.id, name: teacher.name, subject: teacher.subject } } }.to_json
  end
end

teacher_manager = TeacherManager.new

get '/' do
  erb :index
end

get '/teachers' do
  content_type :json
  teacher_manager.to_json
end

post '/teachers' do
  data = JSON.parse(request.body.read)
  name = data['name']
  subject = data['subject']

  teacher_manager.add_teacher(name, subject)
  status 201
end

put '/teachers/sort' do
  teacher_manager.sort_teachers_by_name
  status 200
end

__END__

@@layout
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Teacher Management System</title>
</head>
<body>
  <%= yield %>
</body>
</html>

@@index
<h1>Teacher Management System</h1>
<button onclick="loadTeachers()">Load Teachers</button>
<button onclick="addTeacher()">Add Teacher</button>
<button onclick="sortTeachers()">Sort Teachers by Name</button>
<div id="teacherList"></div>

<script>
  function loadTeachers() {
    fetch('/teachers')
      .then(response => response.json())
      .then(data => {
        const teacherListElement = document.getElementById('teacherList');
        teacherListElement.innerHTML = '<h2>Teacher List</h2>';
        data.teachers.forEach(teacher => {
          teacherListElement.innerHTML += `<p>ID: ${teacher.id}, Name: ${teacher.name}, Subject: ${teacher.subject}</p>`;
        });
      })
      .catch(error => console.error('Error fetching data:', error));
  }

  function addTeacher() {
    const name = prompt('Enter teacher name:');
    const subject = prompt('Enter teacher subject:');
    
    fetch('/teachers', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ name, subject }),
    })
      .then(response => {
        if (response.status === 201) {
          alert('Teacher added successfully!');
        } else {
          alert('Failed to add teacher.');
        }
      })
      .catch(error => console.error('Error adding teacher:', error));
  }

  function sortTeachers() {
    fetch('/teachers/sort', { method: 'PUT' })
      .then(response => {
        if (response.status === 200) {
          alert('Teachers sorted by name.');
          loadTeachers();
        } else {
          alert('Failed to sort teachers.');
        }
      })
      .catch(error => console.error('Error sorting teachers:', error));
  }
</script>
