# frozen_string_literal: true

class SchoolManagersController < UsersController
  def show
    @announcements = policy_scope(Announcement)
  end

  def new
    @user = authorize SchoolManager.new(organisation_id: params[:organisation_id])
    @schools = org_schools
    @orgs = policy_scope(Organisation)

  end

  def edit
    @schools = org_schools
  end

  def create
    @orgs = policy_scope(Organisation)

    organisation_id = school_managers_params[:organisation_id].presence || current_user.organisation_id
    @user = authorize SchoolManager.new(school_managers_params.merge(organisation_id:))

    if @user.save
      redirect_to organisation_school_manager_path(@user.organisation, @user),
                  notice: t('create_success')
    else
      @schools = org_schools
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
    policy_scope(School).order(id: :asc).pluck(:name, :id)
  end

  def school_managers_params
    sm_params = [managements_attributes: %i[id school_id school_manager_id _destroy]]
    params.require(:school_manager).permit(user_params + %i[organisation_id] + sm_params)
  end


  def scoped_users
    super.where(type: 'SchoolManager')
  end
end
