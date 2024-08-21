# frozen_string_literal: true

class TestsController < ApplicationController
  before_action :set_test, only: %i[show edit update destroy]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @tests = policy_scope(Test).order(created_at: :desc)
  end

  def show; end

  def new
    @test = authorize Test.new
    set_courses
  end

  def edit
    set_courses
  end

  def create
    @test = authorize Test.new(test_params)

    if @test.save
      redirect_to tests_url,
                  notice: t('create_success')
    else
      set_courses
      render :new,
             status: :unprocessable_entity,
             alert: t('create_failure')
    end
  end

  def update
    if @test.update(test_params)
      redirect_to tests_url,
                  notice: t('update_success')
    else
      set_courses
      render :edit,
             status: :unprocessable_entity,
             alert: t('update_failure')
    end
  end

  def destroy
    if @test.destroy
      redirect_to tests_url,
                  notice: t('destroy_success')
    else
      redirect_to tests_url,
                  alert: t('destroy_failure')
    end
  end

  private

  def test_params
    params.require(:test).permit(:basics, :name, :level, :questions, :thresholds,
                                 course_tests_attributes: %i[id course_id week _destroy])
  end

  def set_test
    @test = authorize Test.find(params[:id])
  end

  def set_courses
    @courses = policy_scope(Course).includes(:plans)
  end
end
