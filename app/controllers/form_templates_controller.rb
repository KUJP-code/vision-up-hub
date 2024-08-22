# frozen_string_literal: true

class FormTemplatesController < ApplicationController
  def index
    @form_templates = FormTemplate.all
    @orgs = policy_scope(Organisation)
    @org = if params[:organisation_id]
             @orgs.find { |o| o.id == params[:organisation_id].to_i }
           else
             @orgs.first
           end
  end

  def new
    @template = FormTemplate.new(organisation_id: params[:organisation_id])
  end
end
