# frozen_string_literal: true

class OptionCollectionType < ActiveRecord::Type::Value
  def type
    :option_collection
  end

  def cast(string)
    return [] if string.blank?
    return string if string.is_a? Array

    pairs = string.split(',')
    pairs.map { |pair| pair.split(':').map(&:strip) }
  end

  def deserialize(array)
    array.join(', ').join(': ')
  end
end
