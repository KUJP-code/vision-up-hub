class CreateSupportRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :support_requests do |t|
      t.integer :category
      t.string :description
      t.string :internal_notes
      t.datetime :resolved_at
      t.integer :resolved_by
      t.jsonb :seen_by, default: []
      t.string :subject
      t.references :user, null: true, foreign_key: true

      t.timestamps
    end
  end
end
