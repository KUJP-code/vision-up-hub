class CreateTestResults < ActiveRecord::Migration[7.1]
  def change
    create_table :test_results do |t|
      t.integer :total_percent, null: false
      t.integer :write_percent
      t.integer :read_percent
      t.integer :listen_percent
      t.integer :speak_percent
      t.integer :prev_level, null: false
      t.integer :new_level, null: false
      t.references :test, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true

      t.timestamps
    end
  end
end
