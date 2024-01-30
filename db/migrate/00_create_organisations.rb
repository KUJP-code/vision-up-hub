class CreateOrganisations < ActiveRecord::Migration[7.1]
  def change
    create_table :organisations do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone, null: false
      t.string :notes, default: ""

      t.timestamps
    end

    add_index :organisations, :email, unique: true
    add_index :organisations, :phone, unique: true
  end
end
