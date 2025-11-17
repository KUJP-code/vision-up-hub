# frozen_string_literal: true

class Inquiry
  include ActiveModel::Validations, ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :email, :phone, :message, :name, :org,
                :category, :postal_code, :address_pref,
                :address_city, :address_line, :gender, :age

  validates :email, :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :message, presence: true, unless: -> { category == 'join' }
  def initialize(attributes = {})
    attributes.each do |name, value|
      send(:"#{name}=", value)
    end
  end

  def persisted?
    false
  end
end
