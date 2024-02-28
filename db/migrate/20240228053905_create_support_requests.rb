class CreateSupportRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :support_requests do |t|
      t.string :body
      t.jsonb :seen_by
      t.jsonb :internal_comments
      t.datetime :resolved_at
      t.integer :resolved_by
      t.integer :category
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
