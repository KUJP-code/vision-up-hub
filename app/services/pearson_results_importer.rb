# frozen_string_literal: true

require 'csv'

class PearsonResultsImporter
  attr_reader :errors, :inserted, :updated,
              :skipped_unscored, :skipped_unknown_student, :skipped_invalid_date,
              :unknown_samples

  DATE_FORMATS = ['%d/%m/%Y %H:%M:%S', '%m/%d/%Y %H:%M:%S'].freeze

  HEADER_MAP = {
    test_name: 'Test',
    form: 'Form',
    test_id: 'Test id',
    student_name: 'First name', # vendor puts full name here
    external_student_id: 'Last name', # this column actually contains the SSID/external id
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

  def initialize(file, organisation: nil)
    @file = file
    @organisation = organisation
    @errors = []
    @inserted = 0
    @updated  = 0
    @skipped_unscored        = 0
    @skipped_unknown_student = 0
    @skipped_invalid_date    = 0
    @unknown_samples         = []
  end

  def import
    csv = CSV.read(@file.path, headers: true, encoding: 'UTF-8:UTF-8')
    csv.headers.map! { |h| h.to_s.strip }

    rows = csv.map { |row| normalize_row(row) }

    # ---- scope students to org (if given) + normalize ids ----
    scope = @organisation ? Student.where(organisation_id: @organisation.id) : Student.all
    student_map = scope.pluck(:student_id, :id).each_with_object({}) do |(ext_id, sid), h|
      key = normalize_external_id(ext_id)
      h[key] = sid if key.present?
    end

    staged = []
    rows.each do |r|
      # skip unless scored
      status = r[:test_status].to_s.strip.downcase
      if status.present? && status != 'scored'
        @skipped_unscored += 1
        next
      end

      # match by normalized external id
      key = normalize_external_id(r[:external_student_id])
      sid = student_map[key]
      unless sid
        @skipped_unknown_student += 1
        @unknown_samples << r[:external_student_id] if @unknown_samples.size < 25
        next
      end

      taken_at = parse_datetime(r[:test_taken_utc]) || parse_datetime(r[:test_assigned_utc])
      unless taken_at
        @skipped_invalid_date += 1
        next
      end

      listening_score, listening_code = parse_score(r[:listening])
      reading_score,   reading_code   = parse_score(r[:reading])
      writing_score,   writing_code   = parse_score(r[:writing])
      speaking_score,  speaking_code  = parse_score(r[:speaking])

      staged << {
        student_id: sid,
        test_name: r[:test_name].to_s.strip,
        form: r[:form].to_s.strip.presence,
        external_test_id: r[:test_id].to_s.strip.presence&.to_i,
        test_taken_at: taken_at,

        listening_score:, listening_code:,
        reading_score:,   reading_code:,
        writing_score:,   writing_code:,
        speaking_score:,  speaking_code:,

        raw: r[:raw]
      }
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

  def normalize_row(row)
    h = {}
    HEADER_MAP.each { |k, header| h[k] = row[header]&.to_s&.strip }
    h[:raw] = row.to_h
    h
  end

  def normalize_external_id(val)
    # Normalize unicode (full-width digits/letters), trim, drop internal spaces, and upcase.
    # Drop `.upcase` if your student_id is case-sensitive.
    val.to_s.unicode_normalize(:nfkc).strip.gsub(/[[:space:]]+/, '').upcase
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
