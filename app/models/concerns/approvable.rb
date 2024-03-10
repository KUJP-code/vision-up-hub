# frozen_string_literal: true

module Approvable
  extend ActiveSupport::Concern

  included do
    attr_accessor :admin_approval_id, :admin_approval_name,
                  :curriculum_approval_id, :curriculum_approval_name

    before_validation :set_admin_approval, :set_curriculum_approval

    validate :approved_before_release

    def approved?
      admin_approval.any?
    end

    def released?
      released && approved?
    end
  end

  def approved_before_release
    errors.add(:released, 'cannot be set unless approved') if released && !approved?
  end

  def set_admin_approval
    return if already_approved?(:admin_approval, admin_approval_id) ||
              missing_approval_attrs?(:admin_approval_id, :admin_approval_name)

    new_approval = {
      id: admin_approval_id,
      name: admin_approval_name,
      time: Time.zone.now.strftime('%Y-%m-%d %H:%M:%S')
    }
    admin_approval << new_approval
  end

  def set_curriculum_approval
    return if already_approved?(:curriculum_approval, curriculum_approval_id) ||
              missing_approval_attrs?(:curriculum_approval_id, :curriculum_approval_name)

    new_approval = {
      id: curriculum_approval_id,
      name: curriculum_approval_name,
      time: Time.zone.now.strftime('%Y-%m-%d %H:%M:%S')
    }
    curriculum_approval << new_approval
  end

  def already_approved?(approval_type, new_user_id)
    send(approval_type).any? { |a| a['id'] == new_user_id }
  end

  def missing_approval_attrs?(*attrs)
    attrs.any? { |attr| send(attr).blank? }
  end
end
