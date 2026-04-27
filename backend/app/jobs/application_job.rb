class ApplicationJob < ActiveJob::Base
  retry_on ActiveRecord::Deadlocked, wait: :polynomially_longer
  discard_on ActiveJob::DeserializationError
end
