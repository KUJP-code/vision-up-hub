# frozen_string_literal: true

class OrganisationsController < ApplicationController
  before_action :set_organisation, only: %i[edit update]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    authorize Organisation
    @organisations = policy_scope(Organisation).order(updated_at: :desc)
  end

  def new
    @organisation = authorize Organisation.new
  end

  def edit; end

  def create
    @organisation = authorize Organisation.new(organisation_params)

    if @organisation.save
      redirect_to organisations_path,
                  notice: t('create_success', resource: '')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @organisation.update(organisation_params)
      redirect_to organisations_path,
                  notice: t('update_success', resource: '')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def organisation_params
    params.require(:organisation).permit(:name, :email, :phone, :notes)
  end

  def set_organisation
    @organisation = authorize Organisation.find(params[:id])
  end
end
