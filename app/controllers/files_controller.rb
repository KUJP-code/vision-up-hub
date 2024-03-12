# frozen_string_literal: true

class FilesController < ApplicationController
  def show
    @file = ActiveStorage::Blob.find(params[:id])
    @file.update(download_count: @file.download_count + 1)
    send_data @file.download, filename: @file.filename.to_s
  end
end
