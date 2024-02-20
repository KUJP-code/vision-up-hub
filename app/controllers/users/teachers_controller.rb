# frozen_string_literal: true

class TeachersController < UsersController
  def show; end

  def new
    @user = authorize Teacher.new(organisation_id: params[:organisation_id])
    @schools = org_schools
  end

  def edit
    @schools = org_schools
  end

  def create
    @user = authorize Teacher.new(teachers_params)

    if @user.save
      redirect_to organisation_teacher_path(@user.organisation, @user),
                  notice: t('create_success')
    else
      render :new,
             status: :unprocessable_entity,
             alert: t('create_failure')
    end
  end

  def update
    if @user.update(teachers_params)
      redirect_to organisation_teacher_path(@user.organisation, @user),
                  notice: t('update_success')
    else
      render :edit,
             status: :unprocessable_entity,
             alert: t('update_failure')
    end
  end

  private

  def org_schools
    policy_scope(School).pluck(:name, :id)
  end

  def teachers_params
    t_params = [:school_id,
                { school_teachers_attributes: %i[id school_id teacher_id _destroy] }]
    params.require(:teacher).permit(user_params + t_params)
  end

  def scoped_users
    super.where(type: 'Teacher')
  end
end
