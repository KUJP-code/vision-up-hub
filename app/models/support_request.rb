# frozen_string_literal: true

class SupportRequest < ApplicationRecord
  validates :category, :description, :subject, presence: true

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
    save
  end

  def mark_all_unseen
    self.seen_by = []
    save
  end

  def resolved?
    resolved_at.present? && resolved_by.present?
  end

  def seen_by?(user_id)
    seen_by.include?(user_id)
  end

  def self.select_categories
    categories.keys.map do |key|
      [I18n.t("support_requests.categories.#{key}"), key]
    end
  end
end
