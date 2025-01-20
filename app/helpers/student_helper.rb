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
end
