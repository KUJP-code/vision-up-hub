class DropProposedChanges < ActiveRecord::Migration[7.1]
  def change
    drop_table :proposed_changes
  end
end
