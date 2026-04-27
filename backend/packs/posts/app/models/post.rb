class Post < ApplicationRecord
  belongs_to :author, class_name: "User", inverse_of: :posts

  validates :title, presence: true, length: { maximum: 200 }
  validates :body, presence: true, length: { maximum: 50_000 }

  scope :published, -> { where.not(published_at: nil).where("published_at <= ?", Time.current) }
  scope :recent,    -> { order(created_at: :desc) }

  def published?
    published_at.present? && published_at <= Time.current
  end
end
