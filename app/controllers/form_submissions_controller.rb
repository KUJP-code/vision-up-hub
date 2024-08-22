# frozen_string_literal: true

class FormSubmissionsController < ApplicationController
  before_action :set_submission, only: %i[destroy edit update]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @submissions = policy_scope(FormSubmission).includes(:form_template, :staff, :parent)
    @orgs = policy_scope(Organisation)
    @org = if params[:organisation_id]
             @orgs.find { |o| o.id == params[:organisation_id].to_i }
           else
             @orgs.first
           end
  end

  def new
    @submission = authorize FormSubmission.new(organisation_id: params[:organisation_id])
  end

  def edit; end

  def create
    @submission = authorize FormSubmission.new(submission_params)
    if @submission.save
      redirect_to organisation_form_submissions_url(@submission.organisation),
                  notice: t('create_success')
    else
      render :new, status: :unprocessable_entity,
                   alert: t('create_failure')
    end
  end

  def update
    if @submission.update(submission_params)
      redirect_to organisation_form_submissions_url(@submission.organisation),
                  notice: t('update_success')
    else
      render :edit, status: :unprocessable_entity,
                    alert: t('update_failure')
    end
  end

  def destroy
    if @submission.destroy
      redirect_to organisation_form_submissions_url(@submission.organisation),
                  notice: t('destroy_success')
    else
      redirect_to organisation_form_submissions_url(@submission.organisation),
                  alert: t('destroy_failure')
    end
  end

  private

  def submission_params
    params.require(:form_submission).permit(
      :description, :organisation_id, :title,
      fields_attributes: [:explanation, :input_type, :name, :position, :_destroy,
                          { input_attributes_attributes: %i[placeholder required] }]
    )
  end

  def set_submission
    @submission = authorize FormSubmission.find(params[:id])
  end
end
