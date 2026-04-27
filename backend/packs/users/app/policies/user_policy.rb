class UserPolicy < ApplicationPolicy
  def show?
    user.present? && user.id == record.id
  end

  def update?
    show?
  end

  def destroy?
    show?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.present? ? scope.where(id: user.id) : scope.none
    end
  end
end
