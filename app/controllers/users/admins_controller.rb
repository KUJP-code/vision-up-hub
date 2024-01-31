# frozen_string_literal: true

class AdminsController < UsersController
  def show; end

  def update
    if @user.update(admin_params)
      redirect_to organisation_admin_path(@user.organisation, @user),
                  notice: "#{@user.name} successfully updated."
    else
      render :edit,
             status: :unprocessable_entity,
             alert: "Couldn't update admin"
    end
  end

  private

  def admin_params
    a_params = %i[]
    params.require(:admin).permit(user_params + a_params)
  end
end
