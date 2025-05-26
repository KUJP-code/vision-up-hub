# frozen_string_literal: true

class TeachersController < UsersController
  before_action :set_form_data, only: %i[new edit]

  def show
    @levels = %w[kindy elementary keep_up specialist]
              .select { |level| Flipper.enabled?(:"#{level}", @user) }
  end

  def new
    @user = authorize Teacher.new(organisation_id: params[:organisation_id])
    @orgs = policy_scope(Organisation)

  end

  def edit; end

  def create
    @orgs = policy_scope(Organisation)
    organisation_id = teachers_params[:organisation_id].presence || current_user.organisation_id
    @user = authorize Teacher.new(teachers_params.merge(organisation_id:))


    if @user.save
      redirect_to organisation_teacher_path(@user.organisation, @user),
                  notice: t('create_success')
    else
      set_form_data
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
      set_form_data
      render :edit,
             status: :unprocessable_entity,
             alert: t('update_failure')
    end
  end

  private

  def set_form_data
    @schools = policy_scope(School).pluck(:name, :id)
    @classes = policy_scope(SchoolClass).pluck(:name, :id)
  end

  def teachers_params
    t_params = [
      :school_id,
      :organisation_id,
      { school_teachers_attributes: %i[id school_id _destroy] },
      { class_teachers_attributes: %i[id class_id _destroy] }
    ]
    params.require(:teacher).permit(user_params + t_params)
  end


  def scoped_users
    super.where(type: 'Teacher')
  end
end
