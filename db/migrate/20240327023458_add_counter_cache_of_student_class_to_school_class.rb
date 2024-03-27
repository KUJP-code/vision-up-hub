class AddCounterCacheOfStudentClassToSchoolClass < ActiveRecord::Migration[7.1]
  def change
    add_column :school_classes, :students_count, :integer
  end
end
