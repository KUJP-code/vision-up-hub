# frozen_string_literal: true

class FilesController < ApplicationController
  def show
    @file = ActiveStorage::Blob.find(params[:id])
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
    redirect_to course_path(Course.find_by(root_path: @path))
  end
end
