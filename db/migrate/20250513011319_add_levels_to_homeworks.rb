class AddLevelsToHomeworks < ActiveRecord::Migration[7.1]
  def change
    add_column :homeworks, :level, :integer
  end
end
