# frozen_string_literal: true

class StandShowSpeak < Lesson
  ATTRIBUTES = %i[guide].freeze
  LISTABLE_ATTRIBUTES = %i[].freeze

  validate :guide_is_pdf?

  private

  def guide_is_pdf?
    return true unless guide.attached?
    return true if guide.content_type == 'application/pdf'

    errors.add(:guide, 'must be a PDF')
  end
end
