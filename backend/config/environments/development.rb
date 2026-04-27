require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = true
  config.eager_load = false
  config.consider_all_requests_local = true
  config.server_timing = true

  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.cache_store = :solid_cache_store
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  config.active_storage.service = :local

  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: ENV.fetch("SMTP_HOST", "localhost"),
    port: ENV.fetch("SMTP_PORT", 1025).to_i
  }
  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }

  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true
  config.active_job.verbose_enqueue_logs = true
  # In dev, run jobs inline via the :async adapter (in-process threadpool).
  # Avoids the SolidQueue supervisor's fork-after-DB-connect segfault on
  # macOS arm64 with multi-DB. Production still uses :solid_queue
  # (see config/application.rb).
  config.active_job.queue_adapter = :async

  config.action_controller.raise_on_missing_callback_actions = true

  config.hosts.clear
end
