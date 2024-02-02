class CreateLessons < ActiveRecord::Migration[7.1]
  def change
    create_table :lessons do |t|
      t.string :goal, null: false
      t.string :icon, null: false
      t.integer :level, null: false
      t.string :title, null: false
      t.string :type, null: false

      t.timestamps
    end
  end
end
