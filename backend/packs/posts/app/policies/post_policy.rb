class PostPolicy < ApplicationPolicy
  def index?  = true
  def show?   = record.published? || owner?
  def create? = user.present?
  def update?  = owner?
  def destroy? = owner?

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.present?
        scope.where("published_at IS NOT NULL AND published_at <= :now OR author_id = :uid",
          now: Time.current, uid: user.id)
      else
        scope.published
      end
    end
  end

  private

  def owner?
    user.present? && record.author_id == user.id
  end
end
