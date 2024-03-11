module LanguageHelper
  #generates a link to toggle between English and Japanese
  def toggle_locale_link
    current_locale = I18n.locale
    new_locale = (current_locale == :en) ? :ja : :en
    link_to("Switch to #{new_locale.to_s.upcase}", url_for(locale: new_locale))

  end
end
