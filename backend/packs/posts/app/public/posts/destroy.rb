module Posts
  module Destroy
    module_function

    def call(post:)
      if post.destroy
        Shared::Result.success(post)
      else
        Shared::Result.failure(:conflict, post.errors.full_messages.join(", "))
      end
    end
  end
end
