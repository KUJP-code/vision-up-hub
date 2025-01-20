# frozen_string_literal: true

module StudentHelper
  def redact(student, name)
    diff_org = current_user.organisation_id != student.organisation_id
    diff_org ? '****' : name
  end

  def address_for(child)
    render 'schools/address', locals: { school: child.school }
  end
end
