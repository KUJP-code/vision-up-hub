class CreateLessons < ActiveRecord::Migration[7.1]
  def change
    create_table :lessons do |t|
      t.jsonb :admin_approval, default: []
      t.jsonb :curriculum_approval, default: []
      t.string :goal, null: false
      t.string :internal_notes, default: ''
      t.integer :level, null: false
      t.boolean :released, default: false
      t.string :title, null: false
      t.string :type, null: false

      t.integer :creator_id
      t.integer :assigned_editor_id

      t.timestamps
    end

    add_foreign_key :lessons, :users, column: :creator_id
    add_index :lessons, :creator_id
    add_foreign_key :lessons, :users, column: :assigned_editor_id
    add_index :lessons, :assigned_editor_id
  end
end
