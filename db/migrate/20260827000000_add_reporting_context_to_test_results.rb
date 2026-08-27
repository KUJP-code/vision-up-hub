# frozen_string_literal: true

class AddReportingContextToTestResults < ActiveRecord::Migration[7.1]
  def up
    add_column :test_results, :tested_on, :date
    add_reference :test_results, :school, foreign_key: true
    add_reference :test_results, :organisation, foreign_key: true

    execute <<~SQL.squish
      UPDATE test_results
      SET tested_on = test_results.created_at::date,
          school_id = students.school_id,
          organisation_id = students.organisation_id
      FROM students
      WHERE students.id = test_results.student_id
    SQL

    change_column_null :test_results, :tested_on, false
    change_column_null :test_results, :school_id, false
    change_column_null :test_results, :organisation_id, false
  end

  def down
    remove_reference :test_results, :organisation, foreign_key: true
    remove_reference :test_results, :school, foreign_key: true
    remove_column :test_results, :tested_on
  end
end
