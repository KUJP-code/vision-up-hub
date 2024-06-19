class CreateCategoryResources < ActiveRecord::Migration[7.1]
  def change
    create_table :category_resources do |t|
      t.integer :lesson_category
      t.integer :resource_category

      t.timestamps
    end
  end
end
