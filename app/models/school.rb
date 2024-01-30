# frozen_string_literal: true

class School < ApplicationRecord
  validates :name, presence: true

  belongs_to :organisation
  has_many :managements, dependent: :destroy
  has_many :school_managers, through: :managements
end
