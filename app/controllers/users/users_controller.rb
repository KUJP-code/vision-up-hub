# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[edit show update]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @users = policy_scope(User).order(updated_at: :desc).limit(10)
    @users = @users.includes(:organisation) if current_user.is?('Admin')
    @orgs = policy_scope(Organisation).pluck(:name, :id)
    render 'users/index'
  end

  def show
    type = @user.type.underscore.singularize
    redirect_to send(:"organisation_#{type}_path", @user.id,
                     organisation_id: @user.organisation_id, locale: I18n.locale)
  end

  def edit; end

  def update; end

  private

  def set_user
    @user = params[:id] ? User.find(params[:id]) : current_user
    authorize @user
  end

  def user_params
    %i[name email organisation_id password password_confirmation]
  end
end
