class CreateProposedChanges < ActiveRecord::Migration[7.1]
  def change
    create_table :proposed_changes do |t|
      t.string :goal, null: false
      t.string :title, null: false

      t.jsonb :add_difficulty, default: []
      t.jsonb :example_sentences, default: []
      t.jsonb :extra_fun, default: []
      t.jsonb :instructions, default: []
      t.jsonb :intro, default: []
      t.jsonb :large_groups, default: []
      t.jsonb :links, default: {}
      t.jsonb :materials, default: []
      t.jsonb :notes, default: []
      t.jsonb :outro, default: []
      t.integer :subtype
      t.string :topic
      t.jsonb :vocab, default: []

      t.string :comments, default: ''
      t.references :lesson, null: false, foreign_key: true
      t.jsonb :proposals, default: {}
      t.integer :proponent_id, null: false
      t.integer :status, default: 0

      t.timestamps
    end

    add_foreign_key :proposed_changes, :users, column: :proponent_id
    add_index :proposed_changes, :proponent_id
  end
end
