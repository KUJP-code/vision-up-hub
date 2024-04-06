class AddStartDateQuitDateBirthdayToStudent < ActiveRecord::Migration[7.1]
  def change
    add_column :students, :start_date, :date
    add_column :students, :quit_date, :date
    add_column :students, :birthday, :date
  end
end
