# frozen_string_literal: true

class PrivacyPolicy < ApplicationRecord
  has_many :acceptances, class_name: 'PrivacyPolicyAcceptance', dependent: :destroy
  validates :version, presence: true, uniqueness: true

  after_commit :bust_latest_cache, on: %i[create update destroy]

  def self.latest_id
    Rails.cache.fetch('latest_privacy_policy_id') { order(created_at: :desc).limit(1).pluck(:id).first}
  end

  private

  def bust_latest_cache
    Rails.cache.delete('latest_privacy_policy_id')
  end
end
