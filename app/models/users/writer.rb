# frozen_string_literal: true

class Writer < User
  VISIBLE_TYPES = %w[Writer].freeze

  validate :only_at_ku

  has_many :assigned_lessons,
           class_name: 'Lesson',
           dependent: :restrict_with_error,
           foreign_key: :assigned_editor_id,
           inverse_of: :assigned_editor
  has_many :created_lessons,
           class_name: 'Lesson',
           dependent: :restrict_with_error,
           foreign_key: :creator_id,
           inverse_of: :creator
  has_many :proposed_changes,
           dependent: :destroy,
           foreign_key: :proponent_id,
           inverse_of: :proponent

  private

  def only_at_ku
    errors.add(:organisation, 'must be "KidsUP"') unless ku?
  end
end
