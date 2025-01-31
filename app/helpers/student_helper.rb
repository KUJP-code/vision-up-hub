# frozen_string_literal: true

module StudentHelper
  def redact(student, name)
    diff_org = current_user.organisation_id != student.organisation_id
    diff_org ? '****' : name
  end

  def icon_choices
    %w[
      id-art id-boy id-cat id-dino id-dog id-girl id-mic id-music id-robot id-soccer id-princess id-unicorn
    ].freeze
  end

  def icon_path(icon_name)
    "id/#{icon_name}.svg"
  end

  def school_details_for(children)
    return 'No School Currently' unless children.any?

    school = children.first.school

    render partial: 'parents/address', locals: { school: }
  end

  def get_icon(child)
    return default_icon(child) if child.icon_preference.nil?

    icon_path(child.icon_preference) || default_icon(child)
  end

  def default_icon(child)
    return 'id/id-girl.svg' unless child.sex == (:male)

    'id/id-boy.svg'
  end
end
