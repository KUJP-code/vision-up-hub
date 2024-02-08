# frozen_string_literal: true

class Exercise < Lesson
  include ExercisePdf, Linkable, Listable

  LISTABLE_ATTRIBUTES = %i[
    add_difficulty
    extra_fun
    intro
    instructions
    large_groups
    materials
    notes
    outro
    steps
  ].freeze

  before_validation :listify_attributes

  validates :intro, :instructions, presence: true
  validate :image_filetype

  has_one_attached :guide_image

  private

  def image_filetype
    extension = guide_image.content_type.split('/').last
    return if %w[png jpg jpeg].include?(extension)

    guide_image.purge
    errors.add(:guide_image, 'must be a PNG, JPG, or JPEG')
  end
end
