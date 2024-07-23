class AddLevelToCategoryResources < ActiveRecord::Migration[7.1]
  def change
    add_column :category_resources, :level, :integer, default: 0
  end
end
