module Posts
  # Query object — returns published posts most-recent first.
  module Published
    module_function

    def call(scope: Post.all)
      scope.published.recent
    end
  end
end
