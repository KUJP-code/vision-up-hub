# frozen_string_literal: true

class FAQTutorial < ApplicationRecord
  include Tutorials
  attribute :question, :string
  attribute :answer, :string
  attribute :section, :string

  validates :question, presence: true
  validates :answer, presence: true
  validates :section, presence: true
end
