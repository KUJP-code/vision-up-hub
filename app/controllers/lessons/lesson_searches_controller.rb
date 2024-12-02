# frozen_string_literal: true

class LessonSearchesController < ApplicationController
  BOOL_VALUES = %w[released].freeze
  ENUM_VALUES = %w[level status subtype].freeze
  PARTIAL_MATCHES = %w[goal title].freeze

  def index
    @results = policy_scope(Lesson)
    # Apply joins and filters for course_lessons only if needed
    if params[:week].present? || params[:course_id].present?
      @results = @results.joins(:course_lessons)
      @results = @results.where(course_lessons: { week: params[:week] }) if params[:week].present?
      @results = @results.where(course_lessons: { course_id: params[:course_id] }) if params[:course_id].present?
    end
    generic_params = search_params.except(:week, :course_id)
    @results = @results.where(query(generic_params)) if generic_params.present?
    @results = @results.order(created_at: :desc)

    render partial: 'lessons/status_table', locals: { lessons: @results }
  end

  private

  def query(strong_params)
    return {} if strong_params.empty?

    [query_string(strong_params), query_param_hash(strong_params)]
  end

  def search_params
    params.require(:search)
          .permit(:assigned_editor_id, :creator_id, :goal, :level,
                  :released, :status, :subtype, :title, :type, :course_id, :week)
          .compact_blank
  end

  def query_string(strong_params)
    strong_params.keys
                 .map { |k| PARTIAL_MATCHES.include?(k) ? "#{k} LIKE :#{k}" : "#{k} = :#{k}" }
                 .join(' AND ')
  end

  def query_param_hash(strong_params)
    strong_params.to_h { |k, v| [k, sanitized_query_value(k, v)] }
  end

  def sanitized_query_value(key, value)
    if ENUM_VALUES.include?(key)
      value.to_i
    elsif PARTIAL_MATCHES.include?(key)
      "%#{User.sanitize_sql_like(value.strip)}%"
    elsif BOOL_VALUES.include?(key)
      ActiveRecord::Type::Boolean.new.cast(value)
    else
      value
    end
  end
end
