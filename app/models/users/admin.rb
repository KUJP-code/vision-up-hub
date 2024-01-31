# frozen_string_literal: true

class Admin < User
  VISIBLE_TYPES = %w[OrgAdmin Sales SchoolManager Teacher Writer].freeze

  validate :only_at_ku

  private

  def only_at_ku
    errors.add(:organisation, 'must be "KidsUP"') unless organisation&.ku?
  end
end
