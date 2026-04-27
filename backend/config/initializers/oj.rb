# Use Oj for fast JSON parsing & generation, with camelCase keys on the wire.
require "oj"

Oj.optimize_rails
Oj.default_options = { mode: :compat, time_format: :ruby, use_to_json: true }
