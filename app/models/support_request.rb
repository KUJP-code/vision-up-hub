# frozen_string_literal: true

class SupportRequest < ApplicationRecord
  include ImagesAttachable

  validates :category, :description, :subject, presence: true

  enum category: {
    general: 0,
    bug_report: 1,
    typo_report: 2,
    feature_request: 3
  }

  enum priority: {
    low: 0,
    medium: 1,
    high: 2
  }

  belongs_to :user, optional: true
  delegate :organisation_id, to: :user
  has_many :messages,
           dependent: :destroy,
           class_name: 'SupportMessage',
           inverse_of: :support_request

  has_many_attached :images

  def mark_seen_by(user_id)
    seen_by << user_id unless seen_by?(user_id)
    save
  end

  def mark_all_unseen
    self.seen_by = []
    save
  end

  def participants
    participant_ids = (messages.pluck(:user_id) + [user_id]).uniq

    User.where(id: participant_ids)
  end

  def resolved?
    resolved_at.present? && resolved_by.present?
  end

  def seen_by?(user_id)
    seen_by.include?(user_id)
  end
end
