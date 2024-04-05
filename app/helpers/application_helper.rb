# frozen_string_literal: true

module ApplicationHelper
  def ja_date(date)
    return '' if date.nil?

    date.strftime('%Y年%m月%d日')
  end

  def ja_datetime(datetime)
    return '' if datetime.nil?

    datetime.strftime('%Y年%m月%d日 %H:%M')
  end

  def main_nav_link(title, path)
    active = request.path.include?(path)
    active_classes = 'bg-white rounded-lg text-color-main'

    link_to title, path,
            class: "p-3 transition hover:scale-105 #{active_classes if active}"
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

  def locale_toggle
    current_locale = I18n.locale
    new_locale = current_locale == :en ? :ja : :en
    svg_filename = "#{current_locale}.svg"
    svg_tag = image_tag(svg_filename, alt: "Switch to #{new_locale.to_s.upcase}", width: 40, height: 40)
    link_to(
      svg_tag,
      url_for(locale: new_locale),
      class: 'shrink-0 p-3 transition hover:scale-105',
      id: 'locale_toggle',
      title: "Switch to #{new_locale.to_s.upcase}"
    )
  end
end
