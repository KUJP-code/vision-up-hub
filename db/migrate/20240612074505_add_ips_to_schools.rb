class AddIpsToSchools < ActiveRecord::Migration[7.1]
  def change
    add_column :schools, :ip, :string
  end
end
