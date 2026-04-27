module Api
  module V1
    class PostsController < Api::BaseController
      include Pagy::Backend

      skip_before_action :authenticate!, only: %i[index show]
      before_action :authenticate_optional!, only: %i[index show]
      before_action :load_post, only: %i[show update destroy]

      def index
        scope = policy_scope(Post.all)
        @pagy, posts = pagy(scope.recent, items: params.fetch(:per_page, 20))
        render json: {
          data: PostSerializer.new(posts).serializable_hash,
          meta: pagy_metadata(@pagy)
        }
      end

      def show
        authorize @post
        render json: PostSerializer.new(@post).serializable_hash
      end

      def create
        authorize Post
        result = ::Posts::Create.call(author: current_user, attrs: post_params.to_unsafe_h.symbolize_keys)
        render_result(result, success_status: :created, serializer: PostSerializer)
      end

      def update
        authorize @post
        result = ::Posts::Update.call(post: @post, attrs: post_params.to_unsafe_h.symbolize_keys)
        render_result(result, serializer: PostSerializer)
      end

      def destroy
        authorize @post
        result = ::Posts::Destroy.call(post: @post)
        if result.success?
          head :no_content
        else
          render_result(result)
        end
      end

      private

      def authenticate_optional!
        token = bearer_token || cookies.signed[:jwt]
        return unless token

        payload = ::Auth::JwtVerifier.call(token)
        @current_user = User.find_by(id: payload[:user_id])
      rescue ::Auth::InvalidToken
        @current_user = nil
      end

      def load_post
        @post = Post.find(params[:id])
      end

      def post_params
        params.require(:post).permit(:title, :body, :publish)
      end

      def pagy_metadata(pagy)
        { page: pagy.page, pages: pagy.pages, count: pagy.count, items: pagy.vars[:items] }
      end
    end
  end
end
