module Posts
  module Update
    module_function

    def call(post:, attrs:)
      contract = Posts::PostForm.new.call(attrs)
      return Shared::Result.failure(:validation_failed, contract.errors.to_h) if contract.failure?

      data = contract.to_h
      post.title = data[:title]
      post.body = data[:body]
      post.published_at = data[:publish] ? (post.published_at || Time.current) : nil if data.key?(:publish)

      if post.save
        Shared::Result.success(post)
      else
        Shared::Result.failure(:validation_failed, post.errors.full_messages.join(", "))
      end
    end
  end
end
