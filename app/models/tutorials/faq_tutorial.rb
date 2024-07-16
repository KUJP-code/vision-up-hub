# frozen_string_literal: true

class FaqTutorial < ApplicationRecord
  validates :question, presence: true
  validates :answer, presence: true
end
