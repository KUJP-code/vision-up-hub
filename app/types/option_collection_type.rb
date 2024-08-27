# frozen_string_literal: true

class OptionCollectionType < ActiveRecord::Type::Value
  def type
    :option_collection
  end

  def cast(string)
    return [] if string.blank?

    string.split(',').map { |pair| pair.split(':').map(&:strip) }
  end
end
