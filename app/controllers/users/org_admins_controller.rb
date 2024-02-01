# frozen_string_literal: true

class OrgAdminsController < UsersController
  def show; end

  def new
    @user = authorize OrgAdmin.new(organisation_id: params[:organisation_id])
  end

  def create
    @user = authorize OrgAdmin.new(org_admins_params)

    if @user.save
      redirect_to organisation_org_admin_path(@user.organisation, @user),
                  notice: t('create_success')
    else
      render :new,
             status: :unprocessable_entity,
             alert: t('create_failure')
    end
  end

  def update
    if @user.update(org_admins_params)
      redirect_to organisation_org_admin_path(@user.organisation, @user),
                  notice: t('update_success')
    else
      render :edit,
             status: :unprocessable_entity,
             alert: t('update_failure')
    end
  end

  private

  def org_admins_params
    oa_params = %i[]
    params.require(:org_admin).permit(user_params + oa_params)
  end

  def scoped_users
    super.where(type: 'OrgAdmin')
  end
end
