class Blog
  include  DataMapper::Resource

  property :id, Serial
  property :post, Text
end