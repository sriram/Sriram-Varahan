require 'rubygems'
require 'sinatra'
require 'dm-core'

# Configure DataMapper to use the App Engine datastore 
DataMapper.setup(:default, "appengine://auto")

# Create your model class
class Shout
  include DataMapper::Resource

  property :id, Serial
  property :name, Text
  property :message, Text
end

class Blog
  include  DataMapper::Resource

  property :id, Serial
  property :post, Text
end

# Make sure our template can use <%=h
helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/' do
  erb :index
end

get '/about_me' do
  erb :about_me
end

get '/contact_me' do
  erb :contact_me
end

get '/shout_out' do
  # Just list all the shouts
  @shouts = Shout.all
  erb :shout_out
end

get '/blog' do
  # Just list all the shouts
  @shouts = Blog.all
  erb :blog
end

post '/' do
  # Create a new shout and redirect back to the list.
  shout = Shout.create(:name => params[:name],:message => params[:message])
  redirect '/'
end


