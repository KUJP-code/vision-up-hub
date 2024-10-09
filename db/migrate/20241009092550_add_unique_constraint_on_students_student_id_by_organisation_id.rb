class AddUniqueConstraintOnStudentsStudentIdByOrganisationId < ActiveRecord::Migration[7.1]
  def change
    add_index :students, [:student_id, :organisation_id], unique: true
  end
end
