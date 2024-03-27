# frozen_string_literal: true

class UserSearchesController < ApplicationController
  PARTIAL_MATCHES = %w[name email].freeze

  def index
    @results = policy_scope(User).where(query(search_params))
                                 .order(type: :asc, name: :asc)
    @results = @results.includes(:organisation) if current_user.is?('Admin')
    render partial: 'users/table',
           locals: { users: @results }
  end

  private

  def query(strong_params)
    return {} if strong_params.empty?

    [query_string(strong_params), query_param_hash(strong_params)]
  end

  def search_params
    default_params = %i[email name type]
    if current_user.is?('Admin')
      params.require(:search).permit(default_params + %i[organisation_id])
    else
      params.require(:search).permit(default_params)
    end.compact_blank
  end

  def query_string(strong_params)
    strong_params.keys
                 .map { |k| PARTIAL_MATCHES.include?(k) ? "#{k} LIKE :#{k}" : "#{k} = :#{k}" }
                 .join(' AND ')
  end

  def query_param_hash(strong_params)
    strong_params
      .to_h { |k, v| PARTIAL_MATCHES.include?(k) ? [k, "%#{User.sanitize_sql_like(v.strip)}%"] : [k, v] }
  end
end
