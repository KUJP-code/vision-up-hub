# frozen_string_literal: true

class SupportMessage < ApplicationRecord
  belongs_to :support_request
  belongs_to :user, optional: true
  delegate :organisation_id, to: :user
end
