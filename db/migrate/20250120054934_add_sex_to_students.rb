class AddSexToStudents < ActiveRecord::Migration[7.1]
  def change
    add_column :students, :sex, :integer
  end
end
