class CreateInvoices < ActiveRecord::Migration[7.1]
  def change
    create_table :invoices do |t|
      t.references :organisation, null: false, foreign_key: true
      t.integer :number_of_kids, null: false
      t.integer :subtotal, null: false
      t.integer :tax, null: false
      t.integer :total_cost, null: false
      t.datetime :issued_at, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :seen_at
      t.boolean :email_sent, default: false

      t.timestamps
    end

    # Index for faster lookup
    add_index :invoices, :organisation_id, if_not_exists: true
    add_index :invoices, :issued_at, if_not_exists: true
  end
end
