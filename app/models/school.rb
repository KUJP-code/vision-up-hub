# frozen_string_literal: true

class School < ApplicationRecord
  require 'resolv'

  validates :name, presence: true
  validate :valid_ip?

  belongs_to :organisation
  has_many :classes, dependent: :destroy,
                     class_name: 'SchoolClass'
  has_many :managements, dependent: :destroy
  accepts_nested_attributes_for :managements,
                                allow_destroy: true,
                                reject_if: :all_blank
  has_many :school_managers, through: :managements
  has_many :students, dependent: :restrict_with_error
  has_many :test_results, through: :students
  has_many :school_teachers, dependent: :destroy
  accepts_nested_attributes_for :school_teachers,
                                allow_destroy: true,
                                reject_if: :all_blank
  has_many :teachers, through: :school_teachers

  private

  def valid_ip?
    return true if ip.blank? || ip == '*' || Resolv::AddressRegex.match?(ip)

    ips = ip.split(',').map(&:strip)
    invalid_ips = ips.grep_v(Resolv::AddressRegex)
    errors.add(:ip, " #{ip} is not a valid IP address")
    if invalid_ips.any?
      errors.add(:ip, "The following IP address(es) are invalid: #{invalid_ips.join(', ')}")
      return false
    end
    true
  end
end
