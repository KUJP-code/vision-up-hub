# frozen_string_literal: true

class FilePolicy < ApplicationPolicy
  def show?
    return Pundit.policy!(user, report_batch_record).show? if report_batch_file?

    user.is?('Admin', 'OrgAdmin', 'SchoolManager', 'Teacher', 'Writer', 'Parent')
  end

  def destroy?
    return true if user.is?('Admin')
    return false unless user.is?('Writer')

    parent =
      case record
      when ActiveStorage::Attachment then record.record
      when ActiveStorage::Blob
        record.attachments.map(&:record).find { |r| r.is_a?(Lesson) }
      end

    return false unless parent.is_a?(Lesson)

    [parent.creator_id, parent.assigned_editor_id].compact.include?(user.id)
  end

  class Scope < Scope
    def resolve
      user.is?('Admin', 'Writer') ? scope.all : scope.none
    end
  end

  private

  def report_batch_file?
    report_batch_record.present?
  end

  def report_batch_record
    @report_batch_record ||=
      record.attachments
            .map(&:record)
            .find do |attachment_record|
              attachment_record.is_a?(ReportCardBatch) || attachment_record.is_a?(PearsonReportBatch)
            end
  end
end
