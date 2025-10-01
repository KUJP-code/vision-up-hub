# frozen_string_literal: true

class OrganisationTutorialCategory < ApplicationRecord
  belongs_to :organisation
  belongs_to :tutorial_category

  validates :organisation_id,
            uniqueness: { scope: :tutorial_category_id,
                          message: 'is already attached to this category' }
end
