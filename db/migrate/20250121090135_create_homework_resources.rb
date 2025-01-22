class CreateHomeworkResources < ActiveRecord::Migration[7.1]
  def change
    create_table :homework_resources do |t|
      t.integer :week, null: false
      t.references :english_class, null: false, foreign_key: { to_table: :lessons }
      t.references :blob, null: false,
                          foreign_key: { to_table: :active_storage_blobs }
      t.references :course, null: false, foreign_key: true
      t.timestamps
    end
  end
end
