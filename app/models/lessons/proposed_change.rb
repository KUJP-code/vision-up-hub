# frozen_string_literal: true

class ProposedChange < ApplicationRecord
  belongs_to :proponent, class_name: 'User'
  belongs_to :lesson

  enum status: { pending: 0, accepted: 1, rejected: 2 }
end
