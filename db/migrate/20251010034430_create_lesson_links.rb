class CreateLessonLinks < ActiveRecord::Migration[7.1]
  def change
    create_table :lesson_links do |t|
      t.references :lesson, null: false, foreign_key: true
      t.integer :kind, null: false, default: 0
      t.text :url, null: false
      t.text :embed_url
      t.string :title
      t.timestamps
    end

    add_index :lesson_links, :kind

  end
end
