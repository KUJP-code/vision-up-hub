# frozen_string_literal: true

class PearsonUploadsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organisation
  after_action  :verify_authorized

  def show
    authorize :pearson_upload
    if params[:id].to_s == 'sample'
      csv = CSV.generate do |csv|
        csv << ['Test', 'Form', 'Test id', 'First name', 'Last name', 'YL group', 'Test assigned (UTC)',
                'Test taken (UTC)', 'Test status', 'Average score', 'Listening', 'Reading', 'Writing', 'Speaking']
        csv << ['Versant', 'Form 1', '123456', 'Yamada Taro', 'SSID000001', 'YL-A', '04/06/2025 09:00:00',
                '04/06/2025 10:24:53', 'scored', '', 50, 52, 48, 50]
      end
      return send_data csv, filename: 'pearson_sample.csv', type: 'text/csv'
    end
    head :not_found
  end

  def new
    authorize :pearson_upload
    @orgs = current_user.is?('Admin') ? Organisation.order(:name) : [@organisation]
  end

  def create
    authorize :pearson_upload
    file = params.require(:file)

    result = PearsonResultsImporter.new(file.tempfile, organisation: @organisation).import

    if result.errors.any?
      flash.now[:alert] = "Imported with errors. Inserted: #{result.inserted} · Updated: #{result.updated}"
      @errors = result.errors.first(100)
      @errors_overflow = result.errors.size - @errors.size
      @orgs = current_user.is?('Admin') ? Organisation.order(:name) : [@organisation]
      render :new, status: :ok
    else
      redirect_to new_organisation_pearson_upload_path(@organisation),
                  notice: "Inserted: #{result.inserted} · Updated: #{result.updated} · " \
                          "Skipped unscored: #{result.skipped_unscored} · " \
                          "Unknown: #{result.skipped_unknown_student} · " \
                          "Invalid date: #{result.skipped_invalid_date}"
    end
  rescue ActionController::ParameterMissing
    redirect_to new_organisation_pearson_upload_path(@organisation), alert: 'Please choose a CSV file.'
  end

  private

  def set_organisation
    @organisation = Organisation.find(params[:organisation_id])
  end
end
