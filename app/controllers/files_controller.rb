# frozen_string_literal: true

class FilesController < ApplicationController
  def index
    @path = params[:path]
    @files = @path ? ActiveStorage::Blob.where('key LIKE ?', "%#{@path}%") : ActiveStorage::Blob.all
  end

  def show
    @file = ActiveStorage::Blob.find(params[:id])
    @file.update(download_count: @file.download_count + 1)
    send_data @file.download, filename: @file.filename.to_s
  end

  def create
    @path = params[:path]
    @uploads = params[:files]
    @uploads.reject { |u| u == '' }.each do |upload|
      ActiveStorage::Blob.create_and_upload!(
        key: "#{@path}/#{upload.original_filename}",
        io: upload.tempfile,
        filename: upload.original_filename
      )
    end
    redirect_to files_path(path: @path)
  end
end
