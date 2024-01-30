# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[edit show update]

  def show
    type = @user.type.pluralize.parameterize(separator: '_')
    path = "/organisations/#{@user.organisation_id}/#{type}/#{@user.id}"
    redirect_to path
  end

  def edit; end

  def update; end

  private

  def set_user
    @user = params[:id] ? User.find(params[:id]) : current_user
  end
end
