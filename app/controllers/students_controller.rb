# frozen_string_literal: true

class StudentsController < ApplicationController
  before_action :set_student, only: %i[show edit update destroy print_version]
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
    @potential_classes =
      @student.school
              .classes
              .where.not(id: @classes.ids)
              .pluck(:name, :id)
    @orgs = policy_scope(Organisation).pluck(:name, :id)
    @levels = Student.display_levels

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

  def homework_resources
    @student = authorize Student.find(params[:id])
    set_homework_resources
  end

  def print_version
    @student = Student.find(params[:id])
    set_results
    @levels = Student.display_levels
  end

  def report_card_pdf
    @student = Student.find(params[:id])
    authorize @student, :show?

    pdf = StudentReportPdf.new(@student).call
    send_data pdf,
              filename:    "report_card_#{@student.student_id}.pdf",
              disposition: 'inline',
              type:        'application/pdf'
  end

  private

  def set_homework_resources
    @homework_resources = []
    org = @student.organisation

    @plan = org.plans
              .where('start <= ? AND finish_date >= ?', Time.zone.today, Time.zone.today)
              .first
    return unless @plan

    course = Course.find_by(id: @plan.course_id)
    return unless course

    current_week = ((Time.zone.today - @plan.start.to_date).to_i / 7) + 1
    week_range = (current_week - 2..current_week + 2).to_a.select { |w| w.between?(1, 52) }

    @homework_resources = Homework
                          .where(course_id: course.id, level: @student.normalized_level, week: week_range)
                          .includes(:questions_attachment, :answers_attachment)
                          .order(:week)
  end

  def student_params
    params.require(:student).permit(
      :comments, :level, :name, :sex, :status, :school_id, :student_id, :parent_id,
      :en_name, :birthday, :icon_preference, :start_date, :quit_date, :organisation_id,
      student_classes_attributes: %i[id class_id _destroy]
    )
  end

  def set_results
    @results = @student.test_results.order(created_at: :desc).includes(:test)
    @active_result = @results.find { |r| r.test_id == params[:test_id].to_i } if params[:test_id].present?
    @recent_result = @results.first
    @data = radar_data
  end

  def radar_data
    radar_colors = ['49, 44, 180', '221, 50, 50 ', '170, 218, 120', '178, 170, 191'].cycle

    {
      labels: %w[Reading Writing Listening],
      datasets: if @active_result
                  [prepare_dataset(@active_result, radar_colors.next)]
                else
                  @results.map do |result|
                    prepare_dataset(result,
                                    radar_colors.next)
                  end
                end
    }
  end

  def prepare_dataset(result, color)
    {
      data: result.radar_data[:data],
      label: result.radar_data[:label],
      backgroundColor: "rgba(#{color}, 0.2)",
      pointBackgroundColor: '#645880',
      pointBorderColor: '#fff',
      pointHoverBackgroundColor: '#fff',
      pointHoverBorderColor: "rgb(#{color})"
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
