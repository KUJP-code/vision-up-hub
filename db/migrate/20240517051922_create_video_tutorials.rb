class CreateVideoTutorials < ActiveRecord::Migration[7.1]
  def change
    create_table :video_tutorials do |t|
      t.string :title
      t.string :video_path
      t.integer :category

      t.timestamps
    end
  end
end
