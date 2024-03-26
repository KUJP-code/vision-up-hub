# frozen_string_literal: true

module StudentHelper
  def redact(student)
    diff_org = current_user.organisation_id != student.organisation_id
    diff_org ? '****' : student.name
  end
end
