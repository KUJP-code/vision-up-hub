# frozen_string_literal: true

class FaqTutorial < ApplicationRecord
  def self.policy_class
    TutorialPolicy
  end

  belongs_to :tutorial_category

  validates :question, :answer, presence: true

  def type
    'FAQ'
  end
end
