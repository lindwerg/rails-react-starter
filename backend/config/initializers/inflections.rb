# NOTE: do NOT add acronyms (API, JWT, JSON) — Zeitwerk + ActiveSupport
# inflector will then expect constants like `API::Foo` instead of `Api::Foo`,
# breaking autoload of any controller under `packs/*/app/controllers/api/`.
# Keep this empty unless you rename ALL Api/* modules to API/*.
ActiveSupport::Inflector.inflections(:en) do |inflect|
  # inflect.acronym "API"
  # inflect.acronym "JWT"
  # inflect.acronym "JSON"
end
