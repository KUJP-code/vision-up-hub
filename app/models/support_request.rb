# frozen_string_literal: true

class SupportRequest < ApplicationRecord
  validates :body, :category, presence: true

  enum category: {
    general: 0,
    bug_report: 1,
    typo_report: 2,
    feature_request: 3
  }

  belongs_to :user, optional: true
  has_many_attached :attachments

  def mark_seen_by(user_id)
    seen_by << user_id unless seen_by?(user_id)
  end

  def mark_all_unseen
    self.seen_by = []
  end

  def seen_by?(user_id)
    seen_by.include?(user_id)
  end
end
