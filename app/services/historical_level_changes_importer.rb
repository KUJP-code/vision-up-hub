require 'csv'

class HistoricalLevelChangesImporter
  attr_reader :errors

  def initialize(file)
    @file = file
    @errors = []
  end

  def import
    # Process the CSV only once.
    csv = CSV.read(@file.path, headers: true, encoding: 'UTF-8:UTF-8')

    # Normalize headers by stripping whitespace.
    csv.headers.map! { |h| h.to_s.strip }
    csv.each do |row|
      process_row(row)
    end
  rescue StandardError => e
    @errors << "An error occurred while processing the CSV: #{e.message}"
  end

  private

  def process_row(row)
    # Convert to string before stripping.
    student_identifier = row['生徒コード']&.to_s&.strip

    student = Student.find_by(student_id: student_identifier)
    unless student
      @errors << "Student with id '#{student_identifier}' not found. Headers: #{row.headers.inspect}"
      return
    end
    process_level_change_for(student, row, 'LAND1 (レベルクリア)', 'land_one')
    process_level_change_for(student, row, 'LAND2 (レベルクリア)', 'land_two')
    process_level_change_for(student, row, 'SKY1 (レベルクリア)', 'sky_one')
    process_level_change_for(student, row, 'SKY2 (レベルクリア)', 'sky_two')
    process_level_change_for(student, row, 'GALAXY1(レベルクリア)', 'galaxy_one')
  end

  def process_level_change_for(student, row, csv_column, level_identifier)
    return unless row[csv_column].present?

    begin
      date_str = row[csv_column].to_s.strip
      date_cleared = Date.strptime(date_str, '%Y-%m-%d')
    rescue ArgumentError
      @errors << "Invalid date format in #{csv_column} for student #{student.student_id}."
      return
    end

    previous_level = level_identifier
    new_level = new_level_for(level_identifier)
    unless new_level
      @errors << "No mapping found for level identifier '#{level_identifier}' for student #{student.student_id}."
      return
    end

    return if LevelChange.exists?(student_id: student.id, new_level:, date_changed: date_cleared)

    LevelChange.create!(
      student_id: student.id,
      new_level:,
      prev_level: previous_level,
      date_changed: date_cleared
    )
  end

  def new_level_for(level_identifier)
    case level_identifier
    when 'land_one'
      'land_two'
    when 'land_two'
      'sky_one'
    when 'sky_one'
      'sky_two'
    when 'sky_two'
      'galaxy_one'
    when 'galaxy_one'
      'galaxy_two'
    else
      nil
    end
  end
end
