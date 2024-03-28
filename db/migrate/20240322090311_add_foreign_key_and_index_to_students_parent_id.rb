class AddForeignKeyAndIndexToStudentsParentId < ActiveRecord::Migration[7.1]
  add_foreign_key :students, :users, column: :parent_id
  add_index :students, :parent_id
end
