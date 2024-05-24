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
    link_to t(".#{title}"),
            path,
            class: main_nav_class(title, controller_name)
  end

  def main_nav_class(title, controller)
    default_classes = 'p-3 hover:scale-105 transition'
    if controller == title ||
       controller.include?(title) ||
       user_subcontroller?(controller, title)
      return "#{default_classes} text-main bg-white rounded"
    end

    "#{default_classes} text-white"
  end

  def org_favicon(user = nil)
    org_favicons = [1]
    org_id = user ? user.organisation_id : params[:organisation_id].to_i

    favicon_file = org_favicons.include?(org_id) ? "org_#{org_id}.svg" : 'favicon.svg'
    image_path(favicon_file)
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

  def user_subcontroller?(controller, title)
    return false if title != 'users' || current_user_own_profile?
    return true if controller == 'sales'

    controller_as_type = controller.titleize.tr(' ', '').singularize
    User::TYPES.include?(controller_as_type)
  end

  # check the current user profile id vs id in params
  def current_user_own_profile?
    return false unless current_user.present? && params[:id].present?

    current_user.id == params[:id].to_i
  end
end
