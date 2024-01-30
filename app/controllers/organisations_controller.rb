# frozen_string_literal: true

class OrganisationsController < ApplicationController
  before_action :set_organisation, only: %i[edit update]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @organisations = policy_scope(Organisation)
  end

  def new
    @organisation = authorize Organisation.new
  end

  def edit; end

  def create; end

  def update; end

  private

  def set_organisation
    @organisation = Organisation.find(params[:id])
  end
end
