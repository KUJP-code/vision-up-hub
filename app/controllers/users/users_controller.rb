# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[edit show update]
  after_action :verify_authorized, only: %i[edit update]
  after_action :verify_policy_scoped, only: :index

  def index
    @org = params[:organisation_id] && Organisation.find(params[:organisation_id])
    @users = policy_scope(@org ? User.where(organisation_id: @org.id) : User).order(type: :asc, name: :asc)
    @orgs = Organisation.all if current_user.is?('Admin', 'Sales')
  end

  def show
    type = @user.type.pluralize.underscore
    path = "/organisations/#{@user.organisation_id}/#{type}/#{@user.id}"
    redirect_to path
  end

  def edit; end

  def update; end

  private

  def set_user
    @user = params[:id] ? User.find(params[:id]) : current_user
    authorize @user
  end
end
