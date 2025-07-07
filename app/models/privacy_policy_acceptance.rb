class PrivacyPolicyAcceptance < ApplicationRecord
  belongs_to :user
  belongs_to :privacy_policy
  validates accepted_at, presence: true
end
