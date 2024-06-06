class RequireBirthdayOnStudents < ActiveRecord::Migration[7.1]
  def change
    change_column_null :students, :birthday, false
  end
end
