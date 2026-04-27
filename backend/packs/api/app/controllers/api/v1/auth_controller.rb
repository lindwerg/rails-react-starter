module Api
  module V1
    class AuthController < Api::BaseController
      skip_before_action :authenticate!, only: %i[sign_up sign_in]

      def sign_up
        result = ::Auth::SignUp.call(
          email: params.require(:email),
          password: params.require(:password),
          name: params[:name]
        )
        issue_session_for(result)
      end

      def sign_in
        result = ::Auth::SignIn.call(
          email: params.require(:email),
          password: params.require(:password)
        )
        issue_session_for(result)
      end

      def sign_out
        cookies.delete(:jwt)
        head :no_content
      end

      private

      def issue_session_for(result)
        if result.success?
          token = ::Auth::JwtIssuer.call(user_id: result.value.id)
          cookies.signed[:jwt] = {
            value: token,
            httponly: true,
            secure: Rails.env.production?,
            same_site: :lax,
            expires: ENV.fetch("JWT_EXPIRES_IN_HOURS", 24).to_i.hours.from_now
          }
          render json: { user: UserSerializer.new(result.value).serializable_hash, token: token },
            status: result == :sign_in ? :ok : :created
        else
          render json: { error: result.error_message, code: result.error_code },
            status: status_for_error(result.error_code)
        end
      end
    end
  end
end
