# frozen_string_literal: true

class User < ApplicationRecord
  include Notifiable

  KU_TYPES = %w[Admin Sales Writer].freeze
  TYPES = %w[Admin OrgAdmin Parent Sales SchoolManager Teacher Writer].freeze

  validates :name, presence: true
  validates :type, inclusion: { in: TYPES }

  belongs_to :organisation
  has_many :privacy_policy_acceptances, dependent: :destroy
  has_many :support_requests,
           inverse_of: :user,
           dependent: :nullify
  has_many :support_messages,
           inverse_of: :user,
           dependent: :nullify

  # This is the JSONB column, managed by StoreModel
  attribute :notifications, Notification.to_array_type
  validates :notifications, store_model: true

  devise :confirmable, :database_authenticatable, :lockable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def is?(*types)
    types.include?(type)
  end

  def ku?
    return false if organisation_id.nil?

    organisation_id == 1 || organisation.name == 'KidsUP'
  end

  protected

  def send_devise_notification(notification, *)
    devise_mailer.send(notification, self, *).deliver_later
  end
end
