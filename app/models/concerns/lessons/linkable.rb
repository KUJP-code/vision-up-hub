# frozen_string_literal: true

module Linkable
  extend ActiveSupport::Concern

  included do
    before_validation :set_links

    private

    def set_links
      return unless links.instance_of?(String)

      pairs = links.tr("\r", '').split("\n")

      self.links = pairs.to_h do |pair|
        pair_array = pair.split(':', 2)
        return add_errors(input(pair_array)) if missing_info?(pair_array)

        unless http_included?(pair_array[1])
          errors.add(:links, 'must include http:// or https://')
          return self.links = links
        end
        pair_array.map(&:strip)
      end
    end
  end

  def missing_info?(array)
    array.count { |s| !s.empty? } != 2 ||
      array.any?('http')
  end

  def input(array)
    array.reject(&:empty?).first.strip
  end

  def add_errors(input)
    if input.include?('http')
      errors.add(:links, "missing text for #{input}")
    else
      errors.add(:links, "missing for #{input}")
    end
    self.links = links
  end

  def http_included?(link)
    link.include?('http://') ||
      link.include?('https://')
  end
end
