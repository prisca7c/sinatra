# app.rb
require 'sinatra'
require 'sinatra/reloader' if development?

# Sample data for blog posts
$posts = [
  { id: 1, title: 'First Post', content: 'This is the content of the first post.' },
  { id: 2, title: 'Second Post', content: 'This is the content of the second post.' },
  { id: 3, title: 'Third Post', content: 'This is the content of the third post.' }
]

# Display a list of all blog posts
get '/' do
  erb :index, locals: { posts: $posts }
end

# Display a specific blog post
get '/post/:id' do |id|
  post = $posts.find { |p| p[:id].to_s == id }
  erb :post, locals: { post: post }
end

# Form to create a new blog post
get '/new' do
  erb :new
end

# Create a new blog post
post '/create' do
  new_post = {
    id: $posts.length + 1,
    title: params[:title],
    content: params[:content]
  }

  $posts << new_post
  redirect '/'
end

# Layout for the HTML views
__END__

@@layout
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Simple Ruby Blog</title>
</head>
<body>
  <h1>Simple Ruby Blog</h1>
  <%= yield %>
</body>
</html>

@@index
<h2>All Posts</h2>
<ul>
  <% posts.each do |post| %>
    <li><a href="/post/<%= post[:id] %>"><%= post[:title] %></a></li>
  <% end %>
</ul>
<a href="/new">Create a New Post</a>

@@post
<h2><%= post[:title] %></h2>
<p><%= post[:content] %></p>
<a href="/">Back to All Posts</a>

@@new
<h2>Create a New Post</h2>
<form action="/create" method="post">
  <label for="title">Title:</label>
  <input type="text" id="title" name="title" required><br>

  <label for="content">Content:</label>
  <textarea id="content" name="content" required></textarea><br>

  <button type="submit">Create Post</button>
</form>
<a href="/">Back to All Posts</a>
