# frozen_string_literal: true

module Steppable
  extend ActiveSupport::Concern

  included do
    private

    def set_steps
      return unless steps.instance_of?(String)

      self.steps = steps.split("\n")
    end
  end
end
