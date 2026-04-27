module Api
  class BaseController < ApplicationController
    private

    def render_serialized(resource, serializer:, status: :ok, meta: nil)
      payload = serializer.new(resource).serializable_hash
      payload = { data: payload, meta: meta } if meta
      render json: payload, status: status
    end

    def render_result(result, success_status: :ok, serializer: nil)
      if result.success?
        if serializer
          render_serialized(result.value, serializer: serializer, status: success_status)
        else
          render json: result.value, status: success_status
        end
      else
        render json: { error: result.error_message, code: result.error_code },
          status: status_for_error(result.error_code)
      end
    end

    def status_for_error(code)
      case code
      when :validation_failed, :email_taken then :unprocessable_entity
      when :invalid_credentials             then :unauthorized
      when :not_authorized                  then :forbidden
      when :not_found                       then :not_found
      when :conflict                        then :conflict
      else :unprocessable_entity
      end
    end
  end
end
