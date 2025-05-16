class HomeworksController < ApplicationController
  before_action :set_courses
  before_action :set_course, only: %i[index new create destroy]
  before_action :set_homework, only: %i[destroy]
  after_action :verify_policy_scoped, only: %i[index]
  after_action :verify_authorized, except: %i[index]

  def index
    return unless @course

    if current_user.is?('Admin', 'Writer')
      setup_admin_homeworks
    else
      setup_level_grouped_homeworks
    end
  end

  def new
    @homework = @course.homeworks.new
  end

  def create
    @homework = @course.homeworks.find_or_initialize_by(week: homework_params[:week], level: homework_params[:level])
    authorize @homework
    @homework.assign_attributes(homework_params)

    if @homework.save
      redirect_to homeworks_path(course_id: @course.id), notice: 'Homework saved.'
    else
      redirect_to homeworks_path(course_id: @course.id), alert: 'Failed to save homework.'
    end
  end

  def destroy
    @course = @homework.course
    authorize @homework
    @homework.destroy
    redirect_to homeworks_path(course_id: @course.id), notice: 'Homework deleted.'
  end

  private

  def set_homework
    @homework = Homework.find(params[:id])
  end

  def set_course
    @course = Course.find_by(id: params[:course_id]) || @courses.first
  end

  def set_courses
    @courses = policy_scope(Course)
  end

  def setup_admin_homeworks
    @homeworks = @course.homeworks
                        .includes(:questions_attachment, :answers_attachment, 
                                  questions_attachment: :blob, answers_attachment: :blob)
                        .index_by(&:week)

    @homeworks_by_week_and_level = @course.homeworks.index_by { |h| [h.week, h.level] }
  end

  def setup_level_grouped_homeworks
    return unless load_plan

    week_range = current_week_range(@plan)
    homework_scope = load_homework_for_weeks(week_range)

    @homeworks_grouped_by_level = homework_scope.group_by(&:short_level)
    @short_levels = @homeworks_grouped_by_level.keys.sort_by { |lvl| level_sort_index(lvl) }

    if params[:level].blank? && @short_levels.present?
      redirect_to homeworks_path(course_id: @course.id, level: @short_levels.first) and return
    end


    selected_level = params[:level]
    @homework_resources = filter_and_sort_homework(@homeworks_grouped_by_level[selected_level], week_range)
  end

  def level_sort_index(level)
    ordered = ['Land', 'Sky', 'Galaxy', 'Keep Up', 'Specialist']
    ordered.index(level) || 999
  end

  def homework_params
    params.require(:homework).permit(:week, :questions, :answers, :level)
  end

  def load_plan
    @plan = @course.plans
                   .where(organisation_id: current_user.organisation_id)
                   .where('start <= ? AND finish_date >= ?', Time.zone.today, Time.zone.today)
                   .first
  end

  def current_week_range(plan)
    current_week = ((Time.zone.today - plan.start.to_date).to_i / 7) + 1
    (current_week - 2..current_week + 2).to_a.select { |w| w.between?(1, 52) }
  end

  def load_homework_for_weeks(week_range)
    @course.homeworks
           .where(week: week_range)
           .includes(:questions_attachment, :answers_attachment)
  end

  def filter_and_sort_homework(homeworks, week_range)
    return [] unless homeworks

    homeworks.select { |hw| week_range.include?(hw.week) }.sort_by(&:week)
  end
end
