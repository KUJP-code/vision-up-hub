# frozen_string_literal: true

class StudentsController < ApplicationController
  before_action :set_student, only: %i[show edit update destroy]
  before_action :set_form_data, only: %i[edit show]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @students = policy_scope(Student)
                .includes(:school)
                .order(level: :asc, en_name: :asc).limit(300)
    @schools = policy_scope(School).pluck(:name, :id)
  end

  def show
    @classes = @student.classes
    @teachers = @student.teachers
    set_homework_resources
    @potential_classes =
      @student.school
              .classes
              .where.not(id: @classes.ids)
              .pluck(:name, :id)
    @orgs = policy_scope(Organisation).pluck(:name, :id)

    set_results
  end

  def new
    @student = authorize Student.new(school_id: params[:school_id])
    set_form_data
  end

  def edit; end

  def create
    @student = authorize Student.new(student_params)

    if @student.save
      redirect_to @student, notice: t('create_success')
    else
      set_form_data
      render :new,
             status: :unprocessable_entity,
             alert: t('create_failure')
    end
  end

  def update
    Logidze.with_responsible(current_user.id) do
      if @student.update(student_params)
        redirect_to @student, notice: t('update_success')
      else
        set_form_data
        render :edit,
               status: :unprocessable_entity,
               alert: t('update_failure')
      end
    end
  end

  def set_icon
    @student = authorize Student.find(params[:id])
    if @student.update(icon: params[:icon])
      redirect_to @student, notice: t('.update_success')
    else
      redirect_to student_path(@student), alert: t('.update_failure')
    end
  end

  def icon_chooser
    @student = authorize Student.find(params[:id])
    @icon_choices = Student.icon_choices
    render :icon_chooser
  end

  def destroy
    if @student.destroy
      redirect_to students_url,
                  notice: t('destroy_success')
    else
      redirect_to students_url,
                  alert: t('destroy_failure')
    end
  end

  private

  def set_homework_resources
    # TODO: this is super inefficient, i need to nest it
    org = @student.organisation
    plans = org.plans.where('start <= ? AND finish_date >= ?', Time.zone.today, Time.zone.today)
    course_ids = plans.pluck(:course_id)

    lesson_ids =
      if @student.sky?
        Lesson.sky.pluck(:id)
      elsif @student.land?
        Lesson.land.pluck(:id)
      elsif @student.galaxy?
        Lesson.galaxy.pluck(:id)

      end

    @homework_resources = HomeworkResource
                          .where(course_id: course_ids)
                          .where(english_class_id: lesson_ids)
  end

  def student_params
    params.require(:student).permit(
      :comments, :level, :name, :sex, :school_id, :student_id, :parent_id,
      :en_name, :birthday, :icon_preference, :start_date, :quit_date, :organisation_id,
      student_classes_attributes: %i[id class_id _destroy]
    )
  end

  def set_results
    @results = @student.test_results.order(created_at: :desc).includes(:test)
    @results = @results.where(test_id: params[:test_id]) if params[:test_id]
    @data = radar_data
  end

  def radar_data
    radar_colors = ['105, 192, 221', '100, 88, 128', '170, 218, 235',
                    '178, 170, 191'].cycle

    {
      labels: %w[Reading Writing Listening],
      datasets: @results.map do |result|
        data = result.radar_data
        color = radar_colors.next
        {
          data: data[:data],
          label: data[:label],
          backgroundColor: "rgba(#{color}, 0.2)",
          pointBackgroundColor: "rgb(#{color})",
          pointBorderColor: '#fff',
          pointHoverBackgroundColor: '#fff',
          pointHoverBorderColor: "rgb(#{color})"
        }
      end
    }
  end

  def set_form_data
    @classes = policy_scope(SchoolClass).pluck(:name, :id)
    @student.student_classes.build(class_id: params[:class_id]) if params[:class_id]
    @schools = policy_scope(School).pluck(:name, :id)
    @organisations = policy_scope(Organisation).pluck(:name, :id)
  end

  def set_student
    @student = authorize Student.find(params[:id])
  end
end
