# frozen_string_literal: true

module TutorialCategories
  extend ActiveSupport::Concern
  # enum to preset the sections of tutorials
  included do
    enum category: {
      manual: 0,
      worksheets: 1,
      extra_resources: 2,
      hub_manual: 3
    }
  end
end
