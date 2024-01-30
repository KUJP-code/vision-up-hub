class CreateOrganisations < ActiveRecord::Migration[7.1]
  def change
    create_table :organisations do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone, null: false
      t.string :notes, default: ""

      t.timestamps
    end
  end
end
