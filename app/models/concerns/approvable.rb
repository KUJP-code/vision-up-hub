# frozen_string_literal: true

module Approvable
  extend ActiveSupport::Concern

  included do
    attr_accessor :aa_id, :aa_name, :ca_id, :ca_name

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
    return if already_approved?(:admin_approval, aa_id) ||
              missing_approval_attrs?(:aa_id, :aa_name)

    new_approval = {
      id: aa_id,
      name: aa_name,
      time: Time.zone.now.strftime('%Y-%m-%d %H:%M:%S')
    }
    admin_approval << new_approval
  end

  def set_curriculum_approval
    return if already_approved?(:curriculum_approval, ca_id) ||
              missing_approval_attrs?(:ca_id, :ca_name)

    new_approval = {
      id: ca_id,
      name: ca_name,
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
