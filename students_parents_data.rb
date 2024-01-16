require 'json'

class School
  def initialize
    @data_file = 'students_parents_data.json'
    load_data
  end

  def add_student(student)
    @data['students'] << student
    save_data
  end

  def add_parent(parent)
    @data['parents'] << parent
    save_data
  end

  def display_data
    puts 'Students:'
    puts @data['students']

    puts 'Parents:'
    puts @data['parents']
  end

  private

  def load_data
    @data = File.exist?(@data_file) ? JSON.parse(File.read(@data_file)) : { 'students' => [], 'parents' => [] }
  end

  def save_data
    File.write(@data_file, JSON.pretty_generate(@data))
  end
end
