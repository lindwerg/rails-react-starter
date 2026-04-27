Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN_BACKEND"]
  config.breadcrumbs_logger = %i[active_support_logger http_logger]
  config.traces_sample_rate = 0.1
  config.profiles_sample_rate = 0.1
  config.environment = Rails.env
  config.enabled_environments = %w[production staging]
end if defined?(Sentry)
