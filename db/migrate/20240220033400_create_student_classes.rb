class CreateStudentClasses < ActiveRecord::Migration[7.1]
  def change
    create_table :student_classes do |t|
      t.references :student, null: false, foreign_key: true
      t.bigint :class_id

      t.timestamps
    end

    add_foreign_key :student_classes, :school_classes, column: :class_id, null: false
    add_index :student_classes, :class_id
  end
end
