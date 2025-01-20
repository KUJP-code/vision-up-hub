# frozen_string_literal: true

module StudentHelper
  def redact(student, name)
    diff_org = current_user.organisation_id != student.organisation_id
    diff_org ? '****' : name
  end

  def school_details_for(children)
    return 'No School Currently' unless children.any?

    school = children.first.school

    render partial: 'parents/address', locals: { school: }
  end

  def get_icon(child)
    child.icon_preference || default_icon(child)
  end

  def default_icon(child)
    return 'id/id-girl.svg' unless child.sex == (:male)

    'id/id-boy.svg'
  end
end
