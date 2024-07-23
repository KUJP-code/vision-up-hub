# frozen_string_literal: true

class FilesController < ApplicationController
  layout :resolve_layout

  before_action :set_file, only: %i[show destroy]
  after_action :verify_authorized, except: %i[index]
  after_action :verify_policy_scoped, only: %i[index]

  def index
    @files = policy_scope(ActiveStorage::Blob,
                          policy_scope_class: FilePolicy::Scope)
             .order(byte_size: :desc).limit(100)
  end

  def show
    @file.update(download_count: @file.download_count + 1)
  end

  def destroy
    attachment = @file.attachments.find_by(record_id: params[:record_id], record_type: params[:record_type])
    attachment.purge
    redirect_back fallback_location: root_path,
                  notice: 'File deleted.'
  end

  private

  def resolve_layout
    case action_name
    when 'show'
      'file'
    when 'index'
      'application'
    end
  end

  def set_file
    @file = authorize(ActiveStorage::Blob.find(params[:id]),
                      policy_class: FilePolicy)
  end
end
