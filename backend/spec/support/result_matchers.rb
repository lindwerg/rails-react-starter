RSpec::Matchers.define :be_success_result do
  match { |result| result.respond_to?(:success?) && result.success? }
  failure_message { |r| "expected Result to be success, got failure: #{r.error_code} #{r.error_message}" }
end

RSpec::Matchers.define :be_failure_result do |expected_code = nil|
  match do |result|
    result.respond_to?(:failure?) && result.failure? &&
      (expected_code.nil? || result.error_code == expected_code)
  end
  failure_message do |r|
    "expected Result to be failure(#{expected_code}), got: success? = #{r.success?}, code = #{r.error_code}"
  end
end
