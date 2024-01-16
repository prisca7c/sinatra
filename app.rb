# app.rb
require 'sinatra'
require 'json'

get '/' do
  erb :index
end

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
