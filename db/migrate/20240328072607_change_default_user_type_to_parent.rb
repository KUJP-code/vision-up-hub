class ChangeDefaultUserTypeToParent < ActiveRecord::Migration[7.1]
  def change
    change_column_default :users, :type, 'Parent'
  end
end
