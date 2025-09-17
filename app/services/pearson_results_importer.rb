# frozen_string_literal: true

require 'csv'

class PearsonResultsImporter
  attr_reader :errors, :inserted, :updated,
              :skipped_unscored, :skipped_unknown_student, :skipped_invalid_date

  DATE_FORMATS = ['%d/%m/%Y %H:%M:%S', '%m/%d/%Y %H:%M:%S'].freeze

  HEADER_MAP = {
    test_name: 'Test',
    form: 'Form',
    test_id: 'Test id',
    student_name: 'First name', # vendor puts full name here
    ssid: 'Last name', # this column actually contains SSID
    yl_group: 'YL group',
    test_assigned_utc: 'Test assigned (UTC)',
    test_taken_utc: 'Test taken (UTC)',
    test_status: 'Test status',
    average_score: 'Average score',
    listening: 'Listening',
    reading: 'Reading',
    writing: 'Writing',
    speaking: 'Speaking'
  }.freeze

  def initialize(file)
    @file = file
    @errors = []
    @inserted = 0
    @updated  = 0
    @skipped_unscored        = 0
    @skipped_unknown_student = 0
    @skipped_invalid_date    = 0
  end

  def import
    csv = CSV.read(@file.path, headers: true, encoding: 'UTF-8:UTF-8')
    csv.headers.map! { |h| h.to_s.strip }

    normalized = csv.each_with_index.map { |row, _idx| normalize_row(row) }

    # Build map: external SSID → Student.id
    ext_ids = normalized.filter_map { |h| h[:ssid].presence }.uniq
    student_by_ext = Student.where(student_id: ext_ids).pluck(:student_id, :id).to_h

    staged = []
    normalized.each do |row_hash|
      attrs = process_row(row_hash, student_by_ext)
      staged << attrs if attrs
    end

    return self if staged.empty?

    existing = existing_keys_map(staged)
    to_insert, to_update = staged.partition do |h|
      !existing[[h[:student_id], h[:test_name], h[:form], h[:test_taken_at]]]
    end

    PearsonResult.insert_all(to_insert, record_timestamps: true) if to_insert.any?
    if to_update.any?
      PearsonResult.upsert_all(to_update, unique_by: :uniq_pearson_test_sitting,
                                          record_timestamps: true)
    end

    @inserted = to_insert.size
    @updated  = to_update.size
    self
  rescue StandardError => e
    @errors << "Importer failed: #{e.class} — #{e.message}"
    self
  end

  private

  def process_row(r, student_by_ext)
    status = r[:test_status].to_s.strip.downcase
    if status.present? && status != 'scored'
      @skipped_unscored += 1
      return nil
    end

    sid = student_by_ext[r[:ssid]]
    unless sid
      @skipped_unknown_student += 1
      return nil
    end

    taken_at = parse_datetime(r[:test_taken_utc]) || parse_datetime(r[:test_assigned_utc])
    unless taken_at
      @skipped_invalid_date += 1
      return nil
    end

    listening_score, listening_code = parse_score(r[:listening])
    reading_score,   reading_code   = parse_score(r[:reading])
    writing_score,   writing_code   = parse_score(r[:writing])
    speaking_score,  speaking_code  = parse_score(r[:speaking])

    {
      student_id: sid,
      test_name: r[:test_name].to_s.strip,
      form: r[:form].to_s.strip.presence,
      external_test_id: r[:test_id].to_s.strip.presence&.to_i,
      test_taken_at: taken_at,

      listening_score:, listening_code:,
      reading_score:,   reading_code:,
      writing_score:,   writing_code:,
      speaking_score:,  speaking_code:,

      raw: r[:raw] # audit
    }
  end

  def normalize_row(row)
    h = {}
    HEADER_MAP.each { |k, header| h[k] = row[header]&.to_s&.strip }
    h[:raw] = row.to_h
    h
  end

  def parse_datetime(str)
    return nil if str.blank?

    s = str.to_s.strip
    DATE_FORMATS.each do |fmt|
      return DateTime.strptime(s, fmt)
    rescue ArgumentError
      next
    end
    nil
  end

  # -> [score_or_nil, "ok"|"bl"|"ns"]
  def parse_score(cell)
    s = cell.to_s.strip
    return [nil, 'bl'] if s.casecmp('BL').zero?
    return [nil, 'ns'] if s.casecmp('NS').zero?

    s = s.delete('*')
    return [s.to_i, 'ok'] if /\A\d+\z/.match?(s)

    [nil, 'ns']
  end

  def existing_keys_map(staged)
    keys = staged.map { |h| [h[:student_id], h[:test_name], h[:form], h[:test_taken_at]] }.uniq
    return {} if keys.empty?

    conditions = keys.map do
      '(student_id = ? AND test_name = ? AND form IS NOT DISTINCT FROM ? AND test_taken_at = ?)'
    end.join(' OR ')
    found = PearsonResult.where(conditions, *keys.flatten)
                         .pluck(:student_id, :test_name, :form, :test_taken_at)
    found.index_with { |k| true }
  end
end
