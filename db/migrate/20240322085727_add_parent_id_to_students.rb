class AddParentIdToStudents < ActiveRecord::Migration[7.1]
  def change
    add_column :students, :parent_id, :integer
  end
end
