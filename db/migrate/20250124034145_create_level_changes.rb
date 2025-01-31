class CreateLevelChanges < ActiveRecord::Migration[7.1]
  def change
    create_table :level_changes do |t|
      t.references :student, foreign_key: true, null: false
      t.references :test_result, foreign_key: { to_table: :test_results }, null: true
      t.string :new_level, null: false
      t.date :date_changed, null: false

      t.timestamps
    end

    add_index :level_changes, [:student_id, :date_changed, :new_level], unique: true
  end
end
