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
    current_controller = controller.controller_name

    # Get the translated title for display
    translated_title = t(".#{title}")
    # exit early if the current controller matches the provided controller_name
    return link_to(translated_title, path, class: "p-3 bg-white rounded-lg text-color-main") if current_controller.include?(title.downcase)

    user_types = User::TYPES.map(&:downcase)
    # check current profile
    if current_user_own_profile?
      active_class = ''
    else
      if user_types.any? { |type| current_controller.delete('_').include?(type) }
        current_controller = 'users'
      end
      active_class = current_controller == title.downcase ? 'bg-white rounded-lg text-color-main' : ''
    end
    link_to translated_title, path, class: "p-3 #{active_class}"
  end

  def org_theme(user = nil)
    org_themes = [2, 3]
    org_id = user ? user.organisation_id : params[:organisation_id].to_i

    org_themes.include?(org_id) ? "org_#{org_id}" : 'base'
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
    svg_tag = image_tag(svg_filename,
                        alt: "Switch to #{new_locale.to_s.upcase}",
                        width: 40, height: 40)
    link_to(
      svg_tag,
      url_for(locale: new_locale),
      class: 'shrink-0 p-3 flex items-center justify-center transition hover:scale-105',
      id: 'locale_toggle',
      title: "Switch to #{new_locale.to_s.upcase}"
    )
  end

  private

  # check the current user profile id vs id in params
  def current_user_own_profile?
    return false unless current_user.present? && params[:id].present?

    current_user.id == params[:id].to_i
  end
end
