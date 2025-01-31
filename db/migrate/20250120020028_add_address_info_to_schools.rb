class AddAddressInfoToSchools < ActiveRecord::Migration[7.1]
  def change
    add_column :schools, :address, :string
    add_column :schools, :phone_number, :string
    add_column :schools, :email, :string
    add_column :schools, :website, :string
  end
end
