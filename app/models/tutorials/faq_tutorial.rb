# frozen_string_literal: true

class FaqTutorial < ApplicationRecord
  belongs_to :tutorial_category

  validates :question, :answer, presence: true
end
