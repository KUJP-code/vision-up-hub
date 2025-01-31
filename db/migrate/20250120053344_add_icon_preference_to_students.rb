class AddIconPreferenceToStudents < ActiveRecord::Migration[7.1]
  def change
    add_column :students, :icon_preference, :string
  end
end
