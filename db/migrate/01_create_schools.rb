class CreateSchools < ActiveRecord::Migration[7.1]
  def change
    create_table :schools do |t|
      t.string :name, null: false
      t.references :organisation, null: false, foreign_key: true
      t.integer :students_count, default: 0

      t.timestamps
    end
  end
end
