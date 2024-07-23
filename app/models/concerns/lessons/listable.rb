# frozen_string_literal: true

module Listable
  extend ActiveSupport::Concern

  included do
    before_validation :listify_attributes

    private

    def listify_attributes
      self.class::LISTABLE_ATTRIBUTES.each do |attribute|
        send(:"#{attribute}=", listify(send(attribute), attribute))
      end
    end

    def listify(string, attribute)
      return send(attribute) unless string.instance_of?(String)

      string.tr("\r", '').split("\n")
    end
  end
end
