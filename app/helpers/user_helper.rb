# frozen_string_literal: true

module UserHelper
  def viewing_self?
    User::TYPES.include?(controller_name.capitalize.singularize) &&
      current_user.id == params[:id].to_i
  end
end
