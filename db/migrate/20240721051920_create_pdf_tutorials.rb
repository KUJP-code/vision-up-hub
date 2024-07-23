class CreatePdfTutorials < ActiveRecord::Migration[7.1]
  def change
    create_table :pdf_tutorials do |t|
      t.string :title
      t.integer :category
      t.references :tutorial_category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
