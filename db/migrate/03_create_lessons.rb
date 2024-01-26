class CreateLessons < ActiveRecord::Migration[7.1]
  def change
    create_table :lessons do |t|
      t.string :title, null: false
      t.string :summary, null: false
      t.string :type
      t.integer :level, null: false

      t.timestamps
    end
  end
end
