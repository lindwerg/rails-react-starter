require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    config.load_defaults 8.0

    config.autoload_lib(ignore: %w[assets tasks])

    # Packs autoload
    Dir.glob(Rails.root.join("packs/*/app/*")).each do |path|
      config.autoload_paths << path
      config.eager_load_paths << path
    end
    Dir.glob(Rails.root.join("packs/*/app/*/concerns")).each do |path|
      config.autoload_paths << path
      config.eager_load_paths << path
    end

    config.api_only = true

    config.time_zone = "UTC"
    config.active_record.default_timezone = :utc

    config.active_job.queue_adapter = :solid_queue

    config.cache_store = :solid_cache_store

    config.session_store :cookie_store, key: "_app_session", same_site: :lax, secure: Rails.env.production?
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use config.session_store, config.session_options

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.factory_bot dir: "spec/factories"
      g.helper false
      g.assets false
      g.view_specs false
      g.routing_specs false
    end
  end
end
