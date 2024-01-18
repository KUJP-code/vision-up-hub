class AddStepsAndLinksToLesson < ActiveRecord::Migration[7.1]
  def change
    add_column :lessons, :steps, :string, array: true, default: []
    add_column :lessons, :links, :string, array: true, default: []
  end
end
