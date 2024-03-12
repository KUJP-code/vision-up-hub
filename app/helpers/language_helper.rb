module LanguageHelper
  # Generates a link with SVG image to toggle between English and Japanese
  def toggle_locale_link
    current_locale = I18n.locale
    new_locale = (current_locale == :en) ? :ja : :en
    svg_filename = (new_locale == :en) ? 'en.svg' : 'jp.svg'
    svg_tag = image_tag(svg_filename, alt: "Switch to #{new_locale.to_s.upcase}", width: 40, height: 40)
    link_to(svg_tag, url_for(locale: new_locale), class: 'locale-toggle-link', title: "Switch to #{new_locale.to_s.upcase}")
  end
end
