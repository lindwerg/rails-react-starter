module Api
  module V1
    class MeController < Api::BaseController
      def show
        render json: UserSerializer.new(current_user).serializable_hash
      end
    end
  end
end
