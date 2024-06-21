# frozen_string_literal: true

class PhonicsResource < ApplicationRecord
  belongs_to :category_resource
  belongs_to :lesson

  validates :week, presence: true
end
