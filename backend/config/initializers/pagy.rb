require "pagy"
require "pagy/extras/items"
require "pagy/extras/overflow"

Pagy::DEFAULT[:items] = 20
Pagy::DEFAULT[:max_items] = 100
Pagy::DEFAULT[:overflow] = :last_page
