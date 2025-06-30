class ReportCardBatchPolicy < ApplicationPolicy
  def index?
    user.is?('Admin', 'OrgAdmin', 'SchoolManager')
  end
  def show?
    user.is?('Admin', 'OrgAdmin', 'SchoolManager')
  end
  def create?
    user.is?('Admin', 'OrgAdmin', 'SchoolManager')
  end
  def update?
    user.is?('Admin', 'OrgAdmin', 'SchoolManager')
  end
  def regenerate?
    user.is?('Admin', 'OrgAdmin', 'SchoolManager')
  end

  def destroy?  = user.is?('Admin')

  class Scope < Scope
    def resolve
      if user.is?('Admin')
        scope.all
      elsif user.is?('OrgAdmin', 'SchoolManager')
        scope.where(school_id: user.school_ids)
      else
        scope.none
      end
    end
  end

  private

  def can_access_school?
    user.is?('Admin') || user.school_ids.include?(record.school_id)
  end
end
