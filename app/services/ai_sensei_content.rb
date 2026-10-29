# frozen_string_literal: true

class AiSenseiContent
  def self.week_one
    YAML.safe_load_file(Rails.root.join('config/ai_sensei_week_one.yml'))
  end
end
