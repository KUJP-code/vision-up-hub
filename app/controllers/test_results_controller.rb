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
      redirect_to test_test_results_url(test_id: @test_result.test),
                  notice: t('create_success')
    else
      flash.now[:alert] = @test_result.errors.full_messages.to_sentence
      set_index_vars
      render 'test_results/index', status: :unprocessable_entity
    end
  end

  def update
    if @test_result.update(test_result_params)
      redirect_to test_test_results_url(test_id: @test_result.test),
                  notice: t('update_success')
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
                  :new_level, :test_id, :student_id, :reason,
                  { answers: { listening: [], reading: [],
                               speaking: [], writing: [] } })
  end

  def set_index_vars
    @test = Test.find(params[:test_id])
    @students = policy_scope(Student)
                .send(@test.short_level.downcase)
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
