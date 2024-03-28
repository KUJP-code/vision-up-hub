# frozen_string_literal: true

class User < ApplicationRecord
  KU_TYPES = %w[Admin Sales Writer].freeze
  TYPES = %w[Admin OrgAdmin Parent Sales SchoolManager Teacher Writer].freeze

  validates :name, presence: true
  validates :type, inclusion: { in: TYPES }

  belongs_to :organisation
  has_many :support_requests,
           inverse_of: :user,
           dependent: :nullify
  has_many :support_messages,
           inverse_of: :user,
           dependent: :nullify

  devise :confirmable, :database_authenticatable, :lockable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def is?(*types)
    types.include?(type)
  end

  def ku?
    return false if organisation_id.nil?

    organisation_id == 1 || organisation.name == 'KidsUP'
  end
end
