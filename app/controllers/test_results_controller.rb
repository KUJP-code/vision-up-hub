# frozen_string_literal: true

class TestResultsController < ApplicationController
  after_action :verify_authorized, only: %i[create update]
  after_action :verify_policy_scoped, only: :index

  def index
    @test = Test.find(params[:test_id])
    @students = policy_scope(Student).includes(:test_results)
  end

  def create
    @test_result = authorize TestResult.new(test_result_params)

    if @test_result.save
      redirect_to test_test_results_path(@test_result.test),
                  notice: t('create_success')
    else
      render test_test_results_path(@test_result.test),
             status: :unprocessable_entity,
             alert: @test_result.errors
    end
  end

  def update
    @test_result = authorize TestResult.find(params[:id])

    if @test_result.update(test_result_params)
      redirect_to test_test_results_path(@test_result.test),
                  notice: 'update_success'
    else
      render test_test_results_path(@test_result.test),
             status: :unprocessable_entity,
             alert: @test_result.errors
    end
  end

  private

  def test_result_params
    params.require(:test_result).permit(:total_percent, :write_percent, :read_percent, :listen_percent,
                                        :speak_percent, :prev_level, :new_level, :test_id, :student_id,
                                        { answers:
                                          { listening: [], reading: [], speaking: [], writing: [] } })
  end
end
