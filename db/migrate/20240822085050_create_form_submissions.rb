class CreateFormSubmissions < ActiveRecord::Migration[7.1]
  def change
    create_table :form_submissions do |t|
      t.references :parent, null: false, foreign_key: { to_table: :users }
      t.references :staff, null: false, foreign_key: { to_table: :users }
      t.references :organisation, null: false, foreign_key: true
      t.references :form_template, null: false, foreign_key: true
      t.jsonb :responses, default: {}

      t.timestamps
    end
  end
end
