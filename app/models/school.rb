# frozen_string_literal: true

class School < ApplicationRecord
  validates :name, presence: true

  belongs_to :organisation
  has_many :managements, dependent: :destroy
  accepts_nested_attributes_for :managements,
                                allow_destroy: true,
                                reject_if: :all_blank

  has_many :school_managers, through: :managements
  has_many :teachers, dependent: :destroy
end
