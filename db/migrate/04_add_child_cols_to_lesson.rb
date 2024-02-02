class AddDailyActivityColsToLesson < ActiveRecord::Migration[7.1]
  def change
    add_column :lessons, :steps, :jsonb, default: []
    add_column :lessons, :links, :jsonb, default: {}
    add_column :lessons, :subtype, :integer
  end
end
