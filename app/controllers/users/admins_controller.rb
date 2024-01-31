# frozen_string_literal: true

class AdminsController < UsersController
  before_action :set_user, only: %i[show edit update]
  after_action :verify_authorized

  def show
    redirect_to courses_path
  end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to @user,
                  notice: "#{@user.name} successfully updated."
    else
      render :edit,
             status: :unprocessable_entity,
             alert: "Couldn't update admin"
    end
  end
end
