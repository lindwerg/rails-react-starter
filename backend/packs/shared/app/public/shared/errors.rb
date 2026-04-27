module Shared
  module Errors
    Base               = Class.new(StandardError)
    NotAuthorized      = Class.new(Base)
    ValidationFailed   = Class.new(Base)
    NotFound           = Class.new(Base)
    Conflict           = Class.new(Base)
  end
end
