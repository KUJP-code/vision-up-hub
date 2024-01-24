# frozen_string_literal: true

module Linkable
  extend ActiveSupport::Concern

  included do
    private

    def set_links
      return unless links.instance_of?(String)

      pairs = links.split("\n")
      self.links = pairs.to_h { |pair| pair.split(':', 2).map(&:strip) }
    end
  end
end
