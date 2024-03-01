# frozen_string_literal: true

class SupportMessage < ApplicationRecord
  after_commit :mark_sr_unseen, on: :create

  belongs_to :support_request
  belongs_to :user, optional: true
  delegate :organisation_id, to: :user

  private

  def mark_sr_unseen
    support_request.mark_all_unseen
    support_request.save
  end
end
