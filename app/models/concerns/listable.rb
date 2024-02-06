# frozen_string_literal: true

module Listable
  extend ActiveSupport::Concern

  included do
    private

    def listify_attributes
      self.class::LISTABLE_ATTRIBUTES.each do |attribute|
        self[attribute] = listify(self[attribute], attribute)
      end
    end

    def listify(string, attribute)
      return send(attribute) unless string.instance_of?(String)

      string.split("\n")
    end
  end
end
