class CreatePearsonResults < ActiveRecord::Migration[7.1]
  def change
    create_table :pearson_results do |t|
      t.references :student, null: false, foreign_key: true

      t.string :test_name, null: false
      t.string :form
      t.bigint :external_test_id
      t.datetime :test_taken_at, null: false

      t.integer :listening_score
      t.string :listening_code, null: false, default: "ok"
      t.integer :reading_score
      t.string :reading_code, null: false, default: "ok"
      t.integer :writing_score
      t.string :writing_code, null: false, default: "ok"
      t.integer :speaking_score
      t.string :speaking_code, null: false, default: "ok"

      t.jsonb :raw, null: false, default: {}

      t.timestamps
    end
    add_index :pearson_results, :external_test_id
    add_index :pearson_results, [:student_id, :test_name, :form, :test_taken_at],
      unique: true,
      name: "uniq_pearson_test_sitting"
  end
end
