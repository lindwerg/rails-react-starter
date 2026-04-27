module Posts
  # dry-validation contract for Post input.
  class PostForm < Dry::Validation::Contract
    params do
      required(:title).filled(:string, max_size?: 200)
      required(:body).filled(:string, max_size?: 50_000)
      optional(:publish).filled(:bool)
    end
  end
end
