class PrivacyPolicyAcceptance < ApplicationRecord
  belongs_to :user
  belongs_to :privacy_policy
  validates :accepted_at, presence: true
  validates :user_id, uniqueness: { scope: :privacy_policy_id }
end
