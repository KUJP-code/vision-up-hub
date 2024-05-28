# frozen_string_literal: true

class TeacherUploadsController < ApplicationController
  include SampleCsvable

  after_action :verify_authorized, only: %i[create new show update]

  def show
    authorize nil, policy_class: TeacherUploadPolicy
    send_data sample_csv(%w[name email password]),
              filename: 'sample_teachers_upload.csv'
  end

  def new
    authorize nil, policy_class: TeacherUploadPolicy
    @organisation = authorize(Organisation.find(params[:organisation_id]), :update?)
    @orgs = policy_scope(Organisation) if current_user.is?('Admin')
  end

  def create
    @teacher = authorize Teacher.new(teacher_upload_params.merge(organisation_id: params[:organisation_id]))
    @index = params[:index].to_i
    @status = 'Uploaded'
    return if @teacher.save

    set_errors
  end

  def update
    @teacher = authorize Teacher.find_by(email: teacher_upload_params[:email])
    @index = params[:index].to_i
    @status = 'Uploaded'
    return if @teacher.update(teacher_upload_params)

    set_errors
  end

  private

  def teacher_upload_params
    params.require(:teacher_upload).permit(:name, :email, :password, :password_confirmation)
  end

  def set_errors
    @errors = @teacher.errors.full_messages.to_sentence
    @status = 'Error'
  end
end
