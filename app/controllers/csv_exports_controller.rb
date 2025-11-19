# frozen_string_literal: true

class CsvExportsController < ApplicationController
  ALLOWED_MODELS = %w[Lesson TestResult Student].freeze

  after_action :verify_authorized
  before_action :authorize_admin

  def index
    @allowed_models = ALLOWED_MODELS
  end

  def show
    return disallowed_model unless ALLOWED_MODELS.include?(params[:model])

    path = build_path(params[:model])

    if params[:test_id]
      export_results_for_test(path, params[:test_id])
    elsif params[:type]
      export_type_lessons(path, params[:type])
    elsif params[:model] == 'Lesson'
      export_all_lessons(path)
    elsif params[:model] == 'TestResult'
      export_all_test_results(path)
    elsif params[:model] == 'Student'
      export_students_for_current_org(path)
    end

    send_file path, type: 'text/csv', disposition: 'attachment'
  end

  def new
    return disallowed_model unless ALLOWED_MODELS.include?(params[:model])

    send(:"#{params[:model].downcase}_options")
  end

  private

  def build_path(model)
    model_name = model.downcase.pluralize
    time = Time.zone.now.strftime('%Y%m%d%H%M')

    "/tmp/#{model_name}#{time}.csv"
  end

  def authorize_admin
    authorize :csv_export
  end

  def disallowed_model
    redirect_to csv_exports_path,
                alert: "#{params[:model]} is not an allowed model"
  end

  def export_all_lessons(path)
    File.open(path, 'wb') do |f|
      Lesson.copy_to do |line|
        f.write line
      end
    end
  end

  def export_type_lessons(path, type)
    File.open(path, 'wb') do |f|
      Lesson.where(type:).copy_to do |line|
        f.write line
      end
    end
  end

  def export_all_test_results(path)
    File.open(path, 'wb') do |f|
      TestResult.copy_to do |line|
        f.write line
      end
    end
  end

  def export_students_for_current_org(path)
    students = Student.includes(:school).where(organisation_id: current_user.organisation_id)
    headers = %i[name en_name student_id level school_id birthday start_date quit_date sex status]

    CSV.open(path, 'wb') do |csv|
      csv << headers.map(&:to_s) # header row
      students.find_each do |student|
        csv << headers.map { |attr| student.public_send(attr) } # one row per student
      end
    end
  end

  def export_results_for_test(path, test_id)
    headers = test_result_headers(Test.find(test_id))

    CSV.open(path, 'wb') do |csv|
      csv << headers
      TestResult.includes(student: :school)
                .where(test_id:).find_each do |result|
        csv << [result.student.name, result.student.en_name, result.student.student_id,
                result.student.grade, result.student.school.name, result.prev_level.titleize,
                result.basics, *result.listening, *result.reading,
                *result.writing, result.new_level.titleize, result.reason]
      end
    end
  end

  def test_result_headers(test)
    headers = %w[name en_name student_id grade school current_level name_date]
    test.listening.size.times { |i| headers << "listening_#{(i + 97).chr}" }
    test.reading.size.times { |i| headers << "reading_#{(i + 97).chr}" }
    test.writing.size.times { |i| headers << "writing_#{(i + 97).chr}" }
    headers << 'new_level' << 'reason'
  end

  def lesson_options
    @types = Lesson::TYPES
    render 'csv_exports/lesson'
  end

  def testresult_options
    @tests = policy_scope(Test).order(created_at: :desc)
    render 'csv_exports/test_result'
  end
end
