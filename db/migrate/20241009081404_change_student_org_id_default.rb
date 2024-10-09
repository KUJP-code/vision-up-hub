class ChangeStudentOrgIdDefault < ActiveRecord::Migration[7.1]
  def change
    change_column_default :students, :organisation_id, nil
  end
end
