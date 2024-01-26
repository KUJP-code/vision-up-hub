class CreateCourses < ActiveRecord::Migration[7.1]
  def change
    create_table :courses do |t|
      t.string :name, null: false
      t.string :description, default: ''
      t.boolean :released, default: false

      t.timestamps
    end
  end
end
