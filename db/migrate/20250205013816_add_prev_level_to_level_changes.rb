class AddPrevLevelToLevelChanges < ActiveRecord::Migration[7.1]
  def change
    add_column :level_changes, :prev_level, :integer
  end
end
