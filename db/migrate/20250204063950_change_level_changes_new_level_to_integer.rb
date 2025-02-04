class ChangeLevelChangesNewLevelToInteger < ActiveRecord::Migration[7.0]
  def change
    change_column :level_changes, :new_level, :integer, using: 'new_level::integer'
  end
end
