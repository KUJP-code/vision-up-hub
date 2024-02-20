class CreateClassTeachers < ActiveRecord::Migration[7.1]
  def change
    create_table :class_teachers do |t|
      t.bigint :class_id, null: false
      t.references :teacher, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_foreign_key :class_teachers, :school_classes, column: :class_id
    add_index :class_teachers, :class_id
  end
end
