# frozen_string_literal: true

namespace :dev do
  desc "Seed a richer dataset for UI development (5 users, ~50 posts)."
  task seed_rich: :environment do
    abort "❌ dev:seed_rich is development-only" unless Rails.env.development?

    require "faker"

    puts "Seeding rich dataset..."

    demo = User.find_or_create_by!(email: "demo@example.com") do |u|
      u.name = "Demo User"
      u.password = "password123"
    end
    puts "  ✓ user: #{demo.email}"

    other_users = 4.times.map do |i|
      email = "user#{i + 1}@example.com"
      User.find_or_create_by!(email: email) do |u|
        u.name = Faker::Name.name
        u.password = "password123"
      end
    end
    puts "  ✓ users: 4 additional"

    authors = [ demo, *other_users ]

    Post.where("title LIKE ?", "Sample post %").destroy_all

    50.times do |i|
      author = authors.sample
      published = [ true, true, true, false ].sample
      Post.create!(
        title: Faker::Book.title,
        body: Faker::Lorem.paragraphs(number: rand(2..5)).join("\n\n"),
        author: author,
        published_at: published ? rand(30.days.ago..Time.current) : nil
      )
    rescue ActiveRecord::RecordInvalid => e
      warn "  ⚠ skipped a post: #{e.message}"
    end

    published_count = Post.where.not(published_at: nil).count
    draft_count = Post.where(published_at: nil).count
    puts "  ✓ posts: #{published_count} published, #{draft_count} drafts"
    puts "Done. Login with demo@example.com / password123."
  end
end
