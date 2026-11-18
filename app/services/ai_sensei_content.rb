# frozen_string_literal: true

class AiSenseiContent
  WEEKS = { 1 => 'one', 6 => 'six', 19 => 'nineteen' }.freeze

  def self.weeks
    WEEKS.transform_values do |name|
      YAML.safe_load_file(Rails.root.join("config/ai_sensei_week_#{name}.yml"))
    end
  end
end
