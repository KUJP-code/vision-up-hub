# frozen_string_literal: true

module ApplicationHelper
include LanguageHelper
  def split_on_capitals(string)
    string.gsub(/.(?=[[:upper:]])/) { |c| "#{c} " }
  end
end
