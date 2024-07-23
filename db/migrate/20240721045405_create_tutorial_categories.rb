class CreateTutorialCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :tutorial_categories do |t|
      t.string :title, null: false

      t.timestamps
    end

    add_index :tutorial_categories, :title, unique: true
  end
end
