class CreateStudents < ActiveRecord::Migration[7.1]
  def change
    create_table :students do |t|
      t.jsonb :comments
      t.integer :level
      t.string :name
      t.string :student_id
      t.references :school, null: false, foreign_key: true

      t.timestamps
    end
  end
end
