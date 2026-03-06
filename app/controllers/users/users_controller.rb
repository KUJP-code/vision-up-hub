# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[edit show update destroy]
  before_action :load_orgs, only: %i[edit]
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

  def destroy
    fallback_admin = fallback_admin_for(@user)
    return redirect_to users_path, alert: 'Cannot delete user without an admin fallback' if fallback_admin.nil?

    ActiveRecord::Base.transaction do
      reassign_lessons_to_fallback(@user, fallback_admin)
      @user.destroy!
    end

    redirect_to users_path, notice: "#{@user.name} successfully deleted."
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotDestroyed
    redirect_to users_path, alert: "Couldn't delete user"
  end

  private

  def load_orgs
    @orgs = policy_scope(Organisation)
  end

  def set_user
    @user = params[:id] ? User.find(params[:id]) : current_user
    authorize @user
  end

  def user_params
    %i[name email organisation_id password password_confirmation]
  end

  def fallback_admin_for(user)
    Admin.where.not(id: user.id).order(:id).first
  end

  def reassign_lessons_to_fallback(user, fallback_admin)
    Lesson.where(assigned_editor_id: user.id).update_all(assigned_editor_id: fallback_admin.id)
    Lesson.where(creator_id: user.id).update_all(creator_id: fallback_admin.id)
  end
end
