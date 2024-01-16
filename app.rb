# app.rb
require 'sinatra'

get '/' do
  erb :index
end

post '/sort' do
  # Retrieve array from form data
  input_array = params[:input_array].split(',').map(&:to_i)

  # Perform Bubble Sort
  bubble_sort(input_array)

  # Display the sorted array
  erb :index, locals: { sorted_array: input_array }
end

def bubble_sort(arr)
  n = arr.length

  (0..n - 2).each do |i|
    (0..n - i - 2).each do |j|
      arr[j], arr[j + 1] = arr[j + 1], arr[j] if arr[j] > arr[j + 1]
    end
  end
end
