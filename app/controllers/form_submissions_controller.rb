# frozen_string_literal: true

class FormSubmissionsController < ApplicationController
  before_action :set_submission, only: %i[destroy edit show update]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @templates = policy_scope(FormTemplate)
    @submissions = policy_scope(FormSubmission).includes(:form_template, :staff, :parent)
    @orgs = policy_scope(Organisation)
    @org = if params[:organisation_id]
             @orgs.find { |o| o.id == params[:organisation_id].to_i }
           else
             @orgs.first
           end
  end

  def show; end

  def new
    @template = FormTemplate.find(params[:template_id])
    @organisation = authorize Organisation.find(params[:organisation_id])
    @staff = authorize User.find(params[:staff_id]), :show?
    @submission = authorize FormSubmission.new(
      organisation_id: @organisation.id, form_template_id: @template.id
    )
  end

  def edit
    @submission = authorize FormSubmission.find(params[:id])
    set_form_data
  end

  def create
    @submission = authorize FormSubmission.new(submission_params)
    if @submission.save
      redirect_to form_submission_url(@submission),
                  notice: t('create_success')
    else
      set_form_data
      render :new, status: :unprocessable_entity,
                   alert: t('create_failure')
    end
  end

  def update
    if @submission.update(submission_params)
      redirect_to form_submission_url(@submission),
                  notice: t('update_success')
    else
      set_form_data
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
    params.require(:form_submission).permit(:form_template_id, :organisation_id,
                                            :parent_id, :staff_id, :locked, { responses: {} })
  end

  def set_submission
    @submission = authorize FormSubmission.find(params[:id])
  end

  def set_form_data
    @organisation = @submission.organisation
    @template = @submission.form_template
    @staff = @submission.staff
  end
end
