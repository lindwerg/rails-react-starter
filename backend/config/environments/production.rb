require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true

  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.cache_store = :solid_cache_store

  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
  config.assume_ssl = true
  config.force_ssl = true

  config.log_tags = [ :request_id ]
  config.logger = ActiveSupport::TaggedLogging.logger($stdout)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  config.active_storage.service = ENV.fetch("ACTIVE_STORAGE_SERVICE", "local")

  config.active_record.dump_schema_after_migration = false
  config.active_record.attributes_for_inspect = [ :id ]

  config.i18n.fallbacks = true

  config.active_support.report_deprecations = false

  config.silence_healthcheck_path = "/up"

  # Multi-DB: SolidQueue/Cache/Cable each live in their own database
  # (see config/database.yml). Without these the workers query the
  # primary DB and crash with `relation "solid_queue_processes" does
  # not exist`. Production-only — test has a single DB, dev uses :async.
  config.solid_queue.connects_to = { database: { writing: :queue } }
end
