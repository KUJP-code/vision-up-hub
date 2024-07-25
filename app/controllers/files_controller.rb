# frozen_string_literal: true

class FilesController < ApplicationController
  layout 'file'

  before_action :set_file, only: %i[show destroy]
  after_action :verify_authorized

  def show
    @file.update(download_count: @file.download_count + 1)
    send_data @file.download,
              type: @file.content_type,
              filename: @file.filename.to_s,
              disposition: 'inline'
  end

  def destroy
    attachment = @file.attachments.find_by(record_id: params[:record_id], record_type: params[:record_type])
    attachment.purge
    redirect_back fallback_location: root_path,
                  notice: 'File deleted.'
  end

  private

  def set_file
    @file = authorize(ActiveStorage::Blob.find(params[:id]), policy_class: FilePolicy)
  end
end
