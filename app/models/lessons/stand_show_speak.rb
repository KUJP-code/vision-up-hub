# frozen_string_literal: true

class StandShowSpeak < Lesson
  has_one_attached :script do |s|
    s.variant :thumb,
              resize_to_limit: [300, 300],
              convert: :avif,
              preprocessed: true
  end

  # All we need is the script for this lesson type
  def attach_guide; end
end
