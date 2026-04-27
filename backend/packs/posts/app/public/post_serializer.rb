class PostSerializer
  include Alba::Resource

  attributes :id, :title, :body, :published_at, :created_at, :updated_at

  attribute :published do |post|
    post.published?
  end

  attribute :author_id do |post|
    post.author_id
  end
end
