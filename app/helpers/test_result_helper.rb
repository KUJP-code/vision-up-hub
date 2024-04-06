# frozen_string_literal: true

module TestResultHelper
  def fieldname_from_skill(skill)
    skill == 'writing' ? :write_percent : :"#{skill.gsub('ing', '')}_percent"
  end

  def target_from_skill(skill)
    skill == 'writing' ? 'writePercent' : "#{skill.gsub('ing', '')}Percent"
  end
end
