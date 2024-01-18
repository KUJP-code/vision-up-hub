class CreateOrganisations < ActiveRecord::Migration[7.1]
  def change
    create_table :organisations do |t|
      t.string :name, null: false
      t.integer :student_count, default: 0
      t.string :notes, default: ""

      t.timestamps
    end
  end
end
