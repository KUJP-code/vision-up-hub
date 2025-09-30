# frozen_string_literal: true

class OrganisationTutorialCategory < ApplicationRecord
  belongs_to :organisation
  belongs_to :tutorial_category
end
