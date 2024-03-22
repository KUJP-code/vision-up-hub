# frozen_string_literal: true

class ParentsController < UsersController
  def show; end

  def new
    @user = Parent.new
  end

  def create
    @user = authorize Parent.new(parents_params)

    if @user.save
      redirect_to organisation_parent_path(@user.organisation, @user),
                  notice: t('create_success')
    else
      render :new,
             status: :unprocessable_entity,
             alert: t('create_failure')
    end
  end

  def update
    if @user.update(parents_params)
      redirect_to organisation_parent_path(@user.organisation, @user),
                  notice: t('update_success')
    else
      render :edit,
             status: :unprocessable_entity,
             alert: t('update_failure')
    end
  end

  private

  def scoped_users
    super.where(type: 'Parent')
  end

  def parents_params
    p_params = %i[]
    params.require(:user).permit(user_params + p_params)
  end
end
