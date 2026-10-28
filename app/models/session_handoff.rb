# frozen_string_literal: true

class SessionHandoff < ApplicationRecord
  HOSTS = %w[hub.kids-up.app vision-up.app www.vision-up.app].freeze

  belongs_to :user

  def self.issue(user:, host:, state:)
    token = SecureRandom.urlsafe_base64(32)
    where(expires_at: ..Time.current).delete_all
    create!(user:, destination_host: host, state_digest: digest(state), token_digest: digest(token),
            authentication_digest: digest(user.authenticatable_salt), expires_at: 1.minute.from_now)
    token
  end

  def self.redeem(token:, host:, state:)
    return if token.blank?

    transaction do
      grant = lock.find_by(token_digest: digest(token), destination_host: host, state_digest: digest(state))
      if grant
        grant.destroy!
        user = grant.user
        if grant.expires_at.future? && user.active_for_authentication? &&
           ActiveSupport::SecurityUtils.secure_compare(grant.authentication_digest, digest(user.authenticatable_salt))
          user
        end
      end
    end
  end

  def self.digest(value)
    Digest::SHA256.hexdigest(value)
  end
  private_class_method :digest
end
