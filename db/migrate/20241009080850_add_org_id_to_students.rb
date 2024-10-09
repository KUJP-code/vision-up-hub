class AddOrgIdToStudents < ActiveRecord::Migration[7.1]
  def change
    add_reference :students, :organisation, null: false, foreign_key: true, default: 1
  end
end
