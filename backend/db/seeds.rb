# Seeds — used by bin/rails db:seed.

if Rails.env.development?
  puts "Seeding development data..."

  user = User.find_or_create_by!(email: "demo@example.com") do |u|
    u.name = "Demo User"
    u.password = "password123"
  end

  3.times do |i|
    Post.find_or_create_by!(title: "Sample post #{i + 1}") do |p|
      p.body = "This is sample post number #{i + 1}, created by seeds."
      p.author = user
      p.published_at = Time.current
    end
  end

  puts "✓ Seeded 1 user (demo@example.com / password123) and 3 posts."
end
