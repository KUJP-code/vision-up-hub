# frozen_string_literal: true

class Sales < User
  VISIBLE_TYPES = %w[OrgAdmin SchoolManager Sales Teacher].freeze

  validate :only_at_ku

  private

  def only_at_ku
    errors.add(:organisation, 'must be "KidsUP"') unless ku?
  end
end
