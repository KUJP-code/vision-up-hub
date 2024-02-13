# frozen_string_literal: true

class ProposedChange < ApplicationRecord
  belongs_to :proponent, class_name: 'User'
  belongs_to :lesson
end
