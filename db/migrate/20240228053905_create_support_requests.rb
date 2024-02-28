class CreateSupportRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :support_requests do |t|
      t.string :body
      t.integer :category
      t.string :internal_notes
      t.datetime :resolved_at
      t.integer :resolved_by
      t.jsonb :seen_by, default: []
      t.references :user, null: true, foreign_key: true

      t.timestamps
    end
  end
end
