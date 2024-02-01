# frozen_string_literal: true

class SchoolManagersController < UsersController
  def show; end

  def new
    @user = authorize SchoolManager.new(organisation_id: params[:organisation_id])
    @schools = org_schools
  end

  def edit
    @schools = org_schools
  end

  def create
    @user = authorize SchoolManager.new(school_managers_params)

    if @user.save
      redirect_to organisation_school_manager_path(@user.organisation, @user),
                  notice: t('create_success')
    else
      render :new,
             status: :unprocessable_entity,
             alert: t('create_failure')
    end
  end

  def update
    if @user.update(school_managers_params)
      redirect_to organisation_school_manager_path(@user.organisation, @user),
                  notice: t('update_success')
    else
      render :edit,
             status: :unprocessable_entity,
             alert: t('update_failure')
    end
  end

  private

  def org_schools
    @user.organisation.schools.pluck(:name, :id)
  end

  def school_managers_params
    sm_params = [managements_attributes: %i[id school_id school_manager_id _destroy]]
    params.require(:school_manager).permit(user_params + sm_params)
  end

  def scoped_users
    super.where(type: 'SchoolManager')
  end
end
