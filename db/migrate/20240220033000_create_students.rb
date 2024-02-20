class CreateStudents < ActiveRecord::Migration[7.1]
  def change
    create_table :students do |t|
      t.string :name
      t.jsonb :comments
      t.integer :level
      t.references :school, null: false, foreign_key: true

      t.timestamps
    end
  end
end
