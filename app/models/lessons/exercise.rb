# frozen_string_literal: true

class Exercise < Lesson
  ATTRIBUTES = %i[goal guide resources subtype].freeze

  LISTABLE_ATTRIBUTES = %i[].freeze

  enum subtype: {
    aerobics: 0,
    control: 1,
    jumping: 2,
    throwing: 3
  }

  validate :guide_is_pdf?

  private

  def guide_is_pdf?
    return true unless guide.attached?
    return true if guide.content_type == 'application/pdf'

    errors.add(:guide, 'must be a PDF')
  end
end
