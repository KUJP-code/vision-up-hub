# frozen_string_literal: true

module ApplicationHelper
  def ja_date(date)
    date.strftime('%Y年%m月%d日')
  end

  def ja_datetime(datetime)
    datetime.strftime('%Y年%m月%d日 %H:%M')
  end

  def main_nav_link(title, path)
    active = request.path.include?(path)
    active_classes = 'bg-white rounded-lg text-ku-orange'

    link_to title, path,
            class: "p-3 #{active_classes if active}"
  end

  def short_level
    case level
    when 'land_one', 'land_two', 'land_three'
      'Land'
    when 'sky_one', 'sky_two', 'sky_three'
      'Sky'
    when 'galaxy_one', 'galaxy_two', 'galaxy_three'
      'Galaxy'
    when 'keep_up_one', 'keep_up_two'
      'Keep Up'
    when 'specialist', 'specialist_advanced'
      'Specialist'
    else
      level.titleize
    end
  end

  def split_on_capitals(string)
    string.gsub(/.(?=[[:upper:]])/) { |c| "#{c} " }
  end
end
