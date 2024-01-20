# frozen_string_literal: true

class Exercise < Lesson
  enum subtype: {
    outdoor: 0,
    indoor: 1,
    stretching: 2,
    coordination: 3
  }
end
