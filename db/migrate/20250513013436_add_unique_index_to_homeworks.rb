class AddUniqueIndexToHomeworks < ActiveRecord::Migration[7.1]
  def change
    add_index :homeworks, [:course_id, :week, :level], unique: true

  end
end
