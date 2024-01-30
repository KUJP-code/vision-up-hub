class CreateManagements < ActiveRecord::Migration[7.1]
  def change
    create_table :managements do |t|
      t.references :school, null: false, foreign_key: true
      t.references :school_manager,
                   null: false,
                   foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
