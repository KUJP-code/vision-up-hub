class AddBasicsToTest < ActiveRecord::Migration[7.1]
  def change
    add_column :tests, :basics, :integer, default: 0
  end
end
