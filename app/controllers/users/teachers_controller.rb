# frozen_string_literal: true

class TeachersController < UsersController
  before_action :set_form_data, only: %i[new edit]

  def show
    @date = params[:date] ? Date.parse(params[:date]) : Time.zone.today
    lessons = @user.day_lessons(@date)
                   .includes({ resources_attachments: :blob, guide_attachment: :blob })
    @unlevelled_lessons = lessons.unlevelled.released
    @levelled_lessons = lessons.levelled.released
    @resources = @user.category_resources.where
                      .associated(:resource_attachment)
                      .includes(resource_attachment: :blob)
  end

  def new
    @user = authorize Teacher.new(organisation_id: params[:organisation_id])
  end

  def edit; end

  def create
    @user = authorize Teacher.new(teachers_params)

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
    t_params = [:school_id,
                { school_teachers_attributes: %i[id school_id _destroy] },
                { class_teachers_attributes: %i[id class_id _destroy] }]
    params.require(:teacher).permit(user_params + t_params)
  end

  def scoped_users
    super.where(type: 'Teacher')
  end
end
