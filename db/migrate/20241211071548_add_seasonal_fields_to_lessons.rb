class AddSeasonalFieldsToLessons < ActiveRecord::Migration[7.1]
  def change
    add_column :lessons, :event_date, :date
    add_column :lessons, :show_from, :date
    add_column :lessons, :show_until, :date
  end
end
