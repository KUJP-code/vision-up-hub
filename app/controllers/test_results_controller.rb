# frozen_string_literal: true

class TestResultsController < ApplicationController
  before_action :set_result, only: :update
  after_action :verify_authorized, only: %i[create update]
  after_action :verify_policy_scoped, only: :index

  def index
    if current_user.is?('Admin', 'OrgAdmin')
      set_orgs
      set_schools
    end
    set_index_vars
  end

  def create
    @test_result = authorize TestResult.new(test_result_params)

    if @test_result.save
      @test_result.student.track_manual_level_change(@test_result.id) if @test_result.new_level_changed?
      notify_parent(@test_result.student)
      redirect_to school_org_test_path,
                  notice: t('create_success')
    else
      set_index_vars
      render 'test_results/index', status: :unprocessable_entity
    end
  end

  def update
    if @test_result.update(test_result_params)
      @test_result.student.track_manual_level_change(@test_result.id) if @test_result.new_level_changed?
      redirect_to school_org_test_path, notice: t('update_success')
    else
      flash.now[:alert] = @test_result.errors.full_messages.to_sentence
      set_index_vars
      render 'test_results/index', status: :unprocessable_entity
    end
  end

  private

  def test_result_params
    params.require(:test_result)
          .permit(:total_percent, :write_percent, :read_percent,
                  :listen_percent, :speak_percent, :prev_level,
                  :new_level, :test_id, :student_id, :reason, :basics,
                  { answers: { listening: [], reading: [],
                               speaking: [], writing: [] } })
  end

  def notify_parent(student)
    return if student.parent_id.blank?

    NotifyUserJob.perform_later(user_id: student.parent_id,
                                text: t('.result_available', student: student.name),
                                link: student_url(student))
  end

  def school_org_test_path
    test_test_results_url(
      test_id: @test_result.test,
      org_id: @test_result.student.organisation_id,
      school_id: @test_result.student.school_id
    )
  end

  def set_index_vars
    @test = Test.find(params[:test_id])
    @students = policy_scope(Student)
                .send(@test.test_short_level.downcase)
                .or(
                  policy_scope(Student)
                    .where(test_results: { test_id: @test.id })
                )
                .current
                .includes(:school, :test_results)
    @students = @students.where(school_id: @school.id) if current_user.is?('Admin', 'OrgAdmin')
  end

  def set_orgs
    return @org = current_user.organisation if current_user.is?('OrgAdmin')
    return @org = current_user.organisation if params[:org_id].blank?

    @org = authorize Organisation.find(params[:org_id]), :show?
    @orgs = policy_scope(Organisation).where.associated(:schools)
                                      .order(id: :asc)
                                      .distinct.select(:name, :id)
  end

  def set_result
    @test_result = authorize TestResult.find(params[:id])
  end

  def set_schools
    @schools = policy_scope(School).where(organisation_id: @org.id)
                                   .order(id: :asc)
                                   .select(:name, :organisation_id, :id)
    param_school = @schools.find { |s| s.id == params[:school_id].to_i }
    @school = param_school || @schools.first
    authorize @school, :show?
  end
end
