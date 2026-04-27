RSpec::Matchers.define :permit_actions do |actions|
  match { |policy| Array(actions).all? { |a| policy.public_send("#{a}?") } }
  failure_message { |p| "expected policy to permit #{actions.inspect}; results: #{Array(actions).map { |a| [a, p.public_send("#{a}?")] }.to_h}" }
end

RSpec::Matchers.define :forbid_actions do |actions|
  match { |policy| Array(actions).none? { |a| policy.public_send("#{a}?") } }
  failure_message { |p| "expected policy to forbid #{actions.inspect}; results: #{Array(actions).map { |a| [a, p.public_send("#{a}?")] }.to_h}" }
end
