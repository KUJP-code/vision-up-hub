class CreatePearsonReportBatches < ActiveRecord::Migration[7.1]
  def change
    create_table :pearson_report_batches do |t|
      t.references :school, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: 'pending'
      t.string :level, null: false
      t.timestamps
    end

    add_index :pearson_report_batches, [:school_id, :level], unique: true
  end
end
