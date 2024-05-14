# frozen_string_literal: true

class ParentUploadsController < ApplicationController
  after_action :verify_authorized, only: %i[create new update]

  def new
    authorize nil, policy_class: ParentUploadPolicy
    @organisation = authorize(Organisation.find(params[:organisation_id]), :update?)
    @orgs = policy_scope(Organisation) if current_user.is?('Admin')
  end

  def create
    @parent = authorize Parent.new(parent_upload_params.merge(organisation_id: params[:organisation_id]))
    @index = params[:index].to_i
    @status = 'Uploaded'
    return if @parent.save

    set_errors
  end

  def update
    @parent = authorize Parent.find_by(email: parent_upload_params[:email])
    @index = params[:index].to_i
    @status = 'Uploaded'
    return if @parent.update(parent_upload_params)

    set_errors
  end

  private

  def parent_upload_params
    params.require(:parent_upload).permit(:name, :email, :password, :password_confirmation)
  end

  def set_errors
    @errors = @parent.errors.full_messages.to_sentence
    @status = 'Error'
  end
end
