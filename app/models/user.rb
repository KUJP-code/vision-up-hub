# frozen_string_literal: true

class User < ApplicationRecord
  validates :name, presence: true
  enum role: {
    teacher: 0,
    school_manager: 1,
    org_admin: 2,
    sales: 3,
    curriculum: 4,
    admin: 5,
    default: :teacher
  }

  belongs_to :organisation

  devise :confirmable, :database_authenticatable, :lockable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
