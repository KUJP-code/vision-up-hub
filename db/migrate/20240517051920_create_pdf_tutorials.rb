class CreatePdfTutorials < ActiveRecord::Migration[7.1]
  def change
    create_table :pdf_tutorials do |t|
      t.string :title
      t.string :file_path
      t.string :section

      t.timestamps
    end
  end
end
