# frozen_string_literal: true

module Supportable
  extend ActiveSupport::Concern

  included do
    has_many :support_requests,
             foreign_key: :user_id,
             inverse_of: :user,
             dependent: :nullify
    has_many :support_messages,
             foreign_key: :user_id,
             inverse_of: :user,
             dependent: :nullify
  end
end
