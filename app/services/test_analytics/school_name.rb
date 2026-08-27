# frozen_string_literal: true

module TestAnalytics::SchoolName
  def self.english(name)
    I18n.t(name, scope: :school_names, locale: :en, default: name)
  end

  def self.result_count(count)
    "#{count} #{'result'.pluralize(count)}"
  end
end
