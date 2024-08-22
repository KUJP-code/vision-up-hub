# frozen_string_literal: true

class FormTemplatePolicy < ApplicationPolicy
  def show?
    user.is?('Admin') || admin_of_template_org?
  end

  def new?
    user.is?('Admin') || admin_of_template_org?
  end

  def edit?
    user.is?('Admin') || admin_of_template_org?
  end

  def update?
    user.is?('Admin') || admin_of_template_org?
  end

  def create?
    user.is?('Admin') || admin_of_template_org?
  end

  def destroy?
    user.is?('Admin') || admin_of_template_org?
  end

  class Scope < Scope
    def resolve
      case user.type
      when 'Admin'
        scope.all
      when 'OrgAdmin'
        scope.where(organisation_id: user.organisation_id)
      else
        scope.none
      end
    end
  end

  private

  def admin_of_template_org?
    user.is?('OrgAdmin') && user.organisation_id == record.organisation_id
  end
end
