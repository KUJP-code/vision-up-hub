# frozen_string_literal: true

class Writer < User
  VISIBLE_TYPES = %w[].freeze

  validate :only_at_ku

  private

  def only_at_ku
    errors.add(:organisation, 'must be "KidsUP"') unless organisation.ku?
  end
end
