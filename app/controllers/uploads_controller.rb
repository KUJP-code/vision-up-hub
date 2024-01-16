# frozen_string_literal: true

class UploadsController < ApplicationController
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
