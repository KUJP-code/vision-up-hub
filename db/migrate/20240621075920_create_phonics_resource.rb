class CreatePhonicsResource < ActiveRecord::Migration[7.1]
  def change
    create_table :phonics_resources do |t|
      t.references :category_resource, null: false, foreign_key: true
      t.references :lesson, null: false, foreign_key: true
      t.integer :week

      t.timestamps
    end
  end
end
