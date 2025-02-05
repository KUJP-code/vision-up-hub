# frozen_string_literal: true

require 'csv'

class HistoricalLevelChangeImporter
  LEVEL_ORDER = %w[land_1 land_2 sky_1 sky_2 galaxy_1 galaxy_2].freeze

  def self.call(file_path)
    new(file_path).process
  end

  def initialize(file_path)
    @file_path = file_path
    @results = { success: 0, failed: 0, errors: [] }
  end

  def process
    CSV.foreach(@file_path, headers: true, encoding: 'bom|utf-8') do |row|
      student = find_student(row['student_id'])
      next unless student

      LEVEL_ORDER.each_cons(2) do |prev_level, new_level|
        date_column = "#{prev_level}_date"
        date = parse_date(row[date_column])
        next unless date # Skip if no date is provided

        create_level_change(student, prev_level, new_level, date)
      end
    end

    @results
  end

  private

  def find_student(student_id)
    student = Student.find_by(student_id:)
    unless student
      @results[:failed] += 1
      @results[:errors] << "Student ID #{student_id} not found."
    end
    student
  end

  def parse_date(value)
    return nil if value.blank?

    begin
      Date.parse(value)
    rescue ArgumentError
      nil
    end
  end

  def create_level_change(student, prev_level, new_level, date_changed)
    existing = LevelChange.find_by(student:, new_level:, date_changed:)
    return if existing # Skip duplicates

    LevelChange.create!(
      student:,
      prev_level:,
      new_level:,
      date_changed:
    )

    @results[:success] += 1
  rescue ActiveRecord::RecordInvalid => e
    @results[:failed] += 1
    @results[:errors] << "Failed for Student #{student.student_id}: #{e.message}"
  end
end
