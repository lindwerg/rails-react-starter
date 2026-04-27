require "pagy"
require "pagy/extras/limit"
require "pagy/extras/overflow"

Pagy::DEFAULT[:limit]     = 20
Pagy::DEFAULT[:max_limit] = 100
Pagy::DEFAULT[:overflow]  = :last_page
