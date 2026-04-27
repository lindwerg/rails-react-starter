ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup"

# Load the project-root .env (one level above backend/) BEFORE Rails boots, so
# that ENV-driven settings (POSTGRES_PORT, DATABASE_URL, RAILS_MASTER_KEY, …)
# are available to db tasks and one-off `bin/rails` commands too.
# dotenv-rails' Railtie loads only after Rails boots and looks at Rails.root
# (= backend/), but our .env lives at the repo root — so we wire it manually.
begin
  require "dotenv"
  root_env = File.expand_path("../../.env", __dir__)
  Dotenv.load(root_env) if File.exist?(root_env)
rescue LoadError
  # dotenv not in this environment (e.g. production slim image) — fine.
end

require "bootsnap/setup"
