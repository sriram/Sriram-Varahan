# Create your model class
class Shout
  include DataMapper::Resource

  property :id, Serial
  property :name, Text
  property :message, Text
end