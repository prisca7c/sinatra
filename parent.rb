# app/models/parent.rb
class Parent < ApplicationRecord
  has_many :students
end
