class User < ApplicationRecord
  has_secure_password

  EMAIL_REGEX = URI::MailTo::EMAIL_REGEXP

  validates :email,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: EMAIL_REGEX }
  validates :name, length: { maximum: 100 }
  validates :password,
    length: { minimum: 8, maximum: 72 },
    if: -> { password.present? }

  before_save { self.email = email.downcase.strip if email }

  has_many :posts, foreign_key: :author_id, dependent: :destroy, inverse_of: :author
end
