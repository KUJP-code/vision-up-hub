class CreateTests < ActiveRecord::Migration[7.1]
  def change
    create_table :tests do |t|
      t.string :name
      t.integer :level
      t.jsonb :questions, default: {}
      t.jsonb :thresholds, default: {}

      t.timestamps
    end
  end
end
