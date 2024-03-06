class CreatePlans < ActiveRecord::Migration[7.1]
  def change
    create_table :plans do |t|
      t.string :name
      t.string :description
      t.integer :student_limit
      t.date :start
      t.date :end
      t.integer :total_cost
      t.integer :months_paid
      t.references :course, null: false, foreign_key: true
      t.references :organisation, null: false, foreign_key: true

      t.timestamps
    end
  end
end
