# frozen_string_literal: true

class Sales < User
  validate :only_at_ku

  private

  def only_at_ku
    errors.add(:organisation, 'must be "KidsUP"') unless organisation.name == 'KidsUP'
  end
end
