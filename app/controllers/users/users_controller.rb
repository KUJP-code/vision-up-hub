# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[edit show update]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @org = params[:organisation_id] && Organisation.find(params[:organisation_id])
    @users = scoped_users
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

  def scoped_users
    scope = policy_scope(User).order(type: :asc, name: :asc)
    if @org
      scope.where(organisation_id: @org.id)
    else
      scope.includes(:organisation)
    end
  end

  def set_user
    @user = params[:id] ? User.find(params[:id]) : current_user
    authorize @user
  end

  def user_params
    %i[name email password password_confirmation]
  end
end
