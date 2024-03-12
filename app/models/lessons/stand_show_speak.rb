# frozen_string_literal: true

class StandShowSpeak < Lesson
  ATTRIBUTES = %i[guide].freeze

  has_one_attached :guide do |s|
    s.variant :thumb,
              resize_to_limit: [300, 300],
              convert: :avif,
              preprocessed: true
  end

  # We directly upload the guide for this one, just a script
  def attach_guide; end
end
