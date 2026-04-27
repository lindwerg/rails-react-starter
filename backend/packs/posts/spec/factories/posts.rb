FactoryBot.define do
  factory :post do
    author factory: %i[user]
    title { Faker::Book.title }
    body  { Faker::Lorem.paragraph(sentence_count: 3) }
    published_at { Time.current }

    trait :draft do
      published_at { nil }
    end

    trait :scheduled do
      published_at { 1.day.from_now }
    end
  end
end
