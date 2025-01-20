# frozen_string_literal: true

module ApplicationHelper
  def body_classes
    base_classes = 'text-secondary font-medium bg-neutral-light'
    if user_signed_in?
      "#{base_classes} h-[calc(100vh-3.5rem)] w-[calc(100vw-4rem)] ml-16"
    else
      "#{base_classes} h-[calc(100vh-3.5rem)] w-screen"
    end
  end

  def ja_date(date)
    return '' if date.nil?

    date.strftime('%Y年%m月%d日')
  end

  def ja_datetime(datetime)
    return '' if datetime.nil?

    datetime.strftime('%Y年%m月%d日 %H:%M')
  end

  def ja_date_weekday(date)
    weekday = %w[日 月 火 水 木 金 土][date.wday]

    "#{ja_date(date)}(#{weekday})"
  end

  def main_nav_link(title, path)
    active = active_main_nav_link?(title, controller_name)
    link_to path, class: main_nav_class(title, controller_name) do
      (inline_svg_tag "#{title}.svg",
                      class: "w-8 shrink-0 #{'fill-white' if active}") +
        content_tag(:span, t(".#{title}"), class: 'main-nav-link-text')
    end
  end

  def main_nav_class(title, controller)
    return 'main-nav-link' unless active_main_nav_link?(title, controller)

    'main-nav-link active'
  end

  def asset_for_domain(type)
    domain_assets = {
      'hub.kids-up.app' => { nav_logo: 'org_1.svg', favicon: 'favicon.svg', landing: 'landing_logo.svg',
                             splash: 'splash.jpg' }
    }
    default_assets = { nav_logo: 'org_1_vision.svg', favicon: 'favicon_vision.svg', landing: 'landing_logo_vision.svg',
                       splash: 'splash.jpg' }
    domain_assets.fetch(request.host, default_assets)[type]
  end

  def org_favicon(user = nil)
    org_favicons = [1]
    org_id = user ? user.organisation_id : params[:organisation_id].to_i

    favicon_file = org_favicons.include?(org_id) ? "org_#{org_id}.svg" : 'org_1_vision.svg'
    image_path(favicon_file)
  end

  def org_theme(user = nil)
    # If you add a theme, add the org_id to this list
    org_themes = []
    org_id = user ? user.organisation_id : params[:organisation_id].to_i

    org_themes.include?(org_id) ? "org_#{org_id}" : 'base'
  end

  def opts_from(model, attr)
    model.send(attr).keys
         .map { |k| [t(".#{k}"), k] }
  end

  def sanitized_svg(blob)
    sanitize(blob.open(&:read),
             tags: %w[svg defs path style],
             attributes: %w[id xmlns d version encoding viewbox class])
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

  def list_from(array)
    list = array.map { |el| content_tag(:li, el) }
    safe_join(list)
  end

  def locale_toggle(classes: '', turbo_stream: false)
    new_locale = I18n.locale == :en ? :ja : :en
    link_to url_for(request.query_parameters.merge(locale: new_locale)),
            class: main_nav_class('locale', ''),
            id: 'locale_toggle',
            title: "Switch to #{new_locale.to_s.upcase}",
            data: { turbo_stream: } do
      inline_svg_tag "#{new_locale}.svg", class: classes
    end
  end

  private

  def active_main_nav_link?(title, controller)
    controller == title ||
      controller.include?(title) ||
      user_subcontroller?(controller, title)
  end

  def user_subcontroller?(controller, title)
    return true if current_user_own_profile? && %w[home today].include?(title)
    return false if title != 'users' || current_user_own_profile?

    controller_as_type = controller.titleize.tr(' ', '').singularize
    User::TYPES.include?(controller_as_type)
  end

  # check the current user profile id vs id in params
  def current_user_own_profile?
    return false unless current_user.present? && params[:id].present?

    current_user.id == params[:id].to_i
  end
end
