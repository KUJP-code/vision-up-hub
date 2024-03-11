class TestResultsController < ApplicationController
  before_action :set_test_result, only: %i[ show edit update destroy ]

  # GET /test_results
  def index
    @test_results = TestResult.all
  end

  # GET /test_results/1
  def show
  end

  # GET /test_results/new
  def new
    @test_result = TestResult.new
  end

  # GET /test_results/1/edit
  def edit
  end

  # POST /test_results
  def create
    @test_result = TestResult.new(test_result_params)

    if @test_result.save
      redirect_to @test_result, notice: "Test result was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /test_results/1
  def update
    if @test_result.update(test_result_params)
      redirect_to @test_result, notice: "Test result was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /test_results/1
  def destroy
    @test_result.destroy!
    redirect_to test_results_url, notice: "Test result was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_test_result
      @test_result = TestResult.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def test_result_params
      params.require(:test_result).permit(:total_percent, :write_percent, :read_percent, :listen_percent, :speak_percent, :prev_level, :new_level, :test_id, :student_id)
    end
end
