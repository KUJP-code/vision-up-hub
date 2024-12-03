class CreateInvoices < ActiveRecord::Migration[7.1]
  def change
    create_table :invoices do |t|
      t.references :organisation, null: false, foreign_key: true
      t.integer :total_cost, null: false
      t.integer :tax, null: false
      t.integer :subtotal, null: false
      t.integer :number_of_kids, null: false
      t.string :payment_option, null: false
      t.datetime :deleted_at, index: true

      t.timestamps
    end
  end
end