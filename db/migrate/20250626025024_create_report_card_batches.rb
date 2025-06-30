class CreateReportCardBatches < ActiveRecord::Migration[7.1]
  def change
    create_table :report_card_batches do |t|
      t.references :school, null: false, foreign_key: true
      t.references :user,   null: false, foreign_key: true
      t.string     :level,  null: false
      t.string     :status, null: false, default: 'pending'
      t.timestamps
    end

    add_index :report_card_batches, %i[school_id level], unique: true
  end
end
