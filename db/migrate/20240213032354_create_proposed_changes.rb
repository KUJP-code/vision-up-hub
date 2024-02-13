class CreateProposedChanges < ActiveRecord::Migration[7.1]
  def change
    create_table :proposed_changes do |t|
      t.references :lesson, null: false, foreign_key: true
      t.jsonb :proposals
      t.integer :proponent_id, null: false

      t.timestamps
    end

    add_foreign_key :proposed_changes, :users, column: :proponent_id
    add_index :proposed_changes, :proponent_id
  end
end
