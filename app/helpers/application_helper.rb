# frozen_string_literal: true

module ApplicationHelper
  def ja_date(date)
    date.strftime('%Y年%m月%d日')
  end

  def ja_datetime(datetime)
    datetime.strftime('%Y年%m月%d日 %H:%M')
  end

  def main_nav_link(title, path, controller_name)
    user_types = User::TYPES.map(&:downcase)
    current_controller = controller.controller_name
    puts "All user types: #{user_types}"
    active_class = (current_controller == controller_name) ? 'bg-white rounded-lg text-ku-orange' : ''
    link_to title, path, class: "p-3 #{active_class}"
  end
  
  def split_on_capitals(string)
    string.gsub(/.(?=[[:upper:]])/) { |c| "#{c} " }
  end

  def short_level(level)
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

  def toggle_locale_link
    current_locale = I18n.locale
    new_locale = (current_locale == :en) ? :ja : :en
    svg_filename = (new_locale == :en) ? 'en.svg' : 'jp.svg'
    svg_tag = image_tag(svg_filename, alt: "Switch to #{new_locale.to_s.upcase}", width: 40, height: 40)
    link_to(svg_tag, url_for(locale: new_locale), class: 'locale-toggle-link', title: "Switch to #{new_locale.to_s.upcase}")
  end
end
