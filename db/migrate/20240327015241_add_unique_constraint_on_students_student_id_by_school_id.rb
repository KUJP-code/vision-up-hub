class AddUniqueConstraintOnStudentsStudentIdBySchoolId < ActiveRecord::Migration[7.1]
  def change
    add_index :students, %i[student_id school_id], unique: true
  end
end
