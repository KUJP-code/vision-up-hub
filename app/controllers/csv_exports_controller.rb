# frozen_string_literal: true

class CsvExportsController < ApplicationController
  ALLOWED_MODELS = %w[TestResult].freeze

  after_action :verify_authorized
  before_action :check_authorized

  def index
    @allowed_models = ALLOWED_MODELS
  end

  def show
    return disallowed_model unless ALLOWED_MODELS.include?(params[:model])

    model = params[:model].constantize
    path = build_path(params[:model])

    File.open(path, 'wb') do |f|
      if params[:test_id]
        export_results_for_test(f, params[:test_id])
      else
        export_whole_table(model, f)
      end
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

  def check_authorized
    authorize :csv_export
  end

  def disallowed_model
    redirect_to csv_exports_path,
                alert: "#{params[:model]} is not an allowed model"
  end

  def export_results_for_test(file, test_id)
    TestResult.where(test_id:).copy_to do |line|
      file.write line
    end
  end

  def export_whole_table(model, file)
    model.copy_to do |line|
      file.write line
    end
  end

  def testresult_options
    @tests = policy_scope(Test).order(created_at: :desc)
    render 'csv_exports/test_result'
  end
end
