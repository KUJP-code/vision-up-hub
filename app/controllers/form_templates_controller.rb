# frozen_string_literal: true

class FormTemplatesController < ApplicationController
  before_action :set_template, only: %i[destroy edit update]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @form_templates = policy_scope(FormTemplate)
    @orgs = policy_scope(Organisation)
    @org = if params[:organisation_id]
             @orgs.find { |o| o.id == params[:organisation_id].to_i }
           else
             @orgs.first
           end
  end

  def new
    @template = authorize FormTemplate.new(organisation_id: params[:organisation_id])
  end

  def edit; end

  def create
    @template = authorize FormTemplate.new(template_params)
    if @template.save
      redirect_to organisation_form_templates_url(@template.organisation),
                  notice: t('create_success')
    else
      render :new, status: :unprocessable_entity,
                   alert: t('create_failure')
    end
  end

  def update
    if @template.update(template_params)
      redirect_to organisation_form_templates_url(@template.organisation),
                  notice: t('update_success')
    else
      render :edit, status: :unprocessable_entity,
                    alert: t('update_failure')
    end
  end

  def destroy
    if @template.destroy
      redirect_to organisation_form_templates_url(@template.organisation),
                  notice: t('destroy_success')
    else
      redirect_to organisation_form_templates_url(@template.organisation),
                  alert: t('destroy_failure')
    end
  end

  private

  def template_params
    params.require(:form_template).permit(
      :description, :organisation_id, :title,
      fields_attributes: [:explanation, :input_type, :name, :position, :_destroy, :options,
                          { input_attributes_attributes: %i[placeholder required] }]
    )
  end

  def set_template
    @template = authorize FormTemplate.find(params[:id])
  end
end
