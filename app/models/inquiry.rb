# frozen_string_literal: true

class Inquiry
  include ActiveModel::Validations, ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :email, :phone, :message, :name, :org

  validates :email, :message, :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  def initialize(attributes = {})
    attributes.each do |name, value|
      send(:"#{name}=", value)
    end
  end

  def persisted?
    false
  end
end
