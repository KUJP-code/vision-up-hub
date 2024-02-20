class CreateSchoolTeachers < ActiveRecord::Migration[7.1]
  def change
    create_table :school_teachers do |t|
      t.references :school, null: false, foreign_key: true
      t.references :teacher, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
