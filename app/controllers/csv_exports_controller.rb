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
      model.copy_to do |line|
        f.write line
      end
    end

    send_file path, type: 'text/csv', disposition: 'attachment'
  end

  def new
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
end
