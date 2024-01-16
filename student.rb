# app/models/student.rb
class Student < ApplicationRecord
  belongs_to :parent
end
