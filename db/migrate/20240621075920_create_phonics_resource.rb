class CreatePhonicsResource < ActiveRecord::Migration[7.1]
  def change
    create_table :phonics_resources do |t|
      t.references :blob, null: false,
                          foreign_key: { to_table: :active_storage_blobs }
      t.references :phonics_class, null: false,
                                   foreign_key: { to_table: :lessons }
      t.integer :week

      t.timestamps
    end
  end
end
