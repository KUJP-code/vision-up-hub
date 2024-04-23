# frozen_string_literal: true

module Tutorials
  extend ActiveSupport::Concern
  # enum to preset the sections of tutorials
  included do
    enum section: {
      english_class: 'English class Tutorial / sample',
      phonics_class: 'Phonics class Tutorial / sample',
      stationery: 'Stationery Tutorial / sample',
      extra_resources: 'Extra Resources',
      phonics: 'Phonics Tutorial / sample',
      web_manual: 'Web Manual (How to)',
      faq: 'FAQ',
      active_learning: 'Active Learning Tutorial / Sample'
    }
  end
end
