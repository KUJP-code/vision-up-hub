# frozen_string_literal: true

class SupportMessage < ApplicationRecord
  include ImagesAttachable

  after_commit :mark_request_unseen, on: :create

  belongs_to :support_request
  belongs_to :user, optional: true
  delegate :organisation_id, to: :user

  private

  def mark_request_unseen
    support_request.mark_all_unseen
    support_request.save
  end
end
