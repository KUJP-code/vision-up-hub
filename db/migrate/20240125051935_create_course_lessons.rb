class CreateCourseLessons < ActiveRecord::Migration[7.1]
  def change
    create_table :course_lessons do |t|
      t.references :course, null: false, foreign_key: true
      t.references :lesson, null: false, foreign_key: true
      t.integer :week, null: false
      t.integer :day, null: false

      t.timestamps
    end
  end
end
