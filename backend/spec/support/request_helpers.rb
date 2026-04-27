module RequestHelpers
  def json_body
    @json_body ||= JSON.parse(response.body, symbolize_names: true)
  end

  def auth_headers_for(user)
    token = Auth::JwtIssuer.call(user_id: user.id)
    { "Authorization" => "Bearer #{token}" }
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end
