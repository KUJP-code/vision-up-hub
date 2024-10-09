class RemoveIndexStudentIdBySchoolId < ActiveRecord::Migration[7.1]
  def change
    remove_index :students, column: [:student_id, :school_id]
  end
end
