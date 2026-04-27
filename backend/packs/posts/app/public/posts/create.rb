module Posts
  module Create
    module_function

    def call(author:, attrs:)
      contract = Posts::PostForm.new.call(attrs)
      return Shared::Result.failure(:validation_failed, contract.errors.to_h) if contract.failure?

      data = contract.to_h
      post = author.posts.build(
        title: data[:title],
        body: data[:body],
        published_at: data[:publish] ? Time.current : nil
      )

      if post.save
        Shared::Result.success(post)
      else
        Shared::Result.failure(:validation_failed, post.errors.full_messages.join(", "))
      end
    end
  end
end
