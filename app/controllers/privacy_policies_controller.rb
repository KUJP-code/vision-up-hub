# frozen_string_literal: true

class PrivacyPoliciesController < ApplicationController
  before_action :authorize_admin!

  def new
    @policy = PrivacyPolicy.new
  end

  def show
    @policy = params[:id] == 'preview' ? preview_policy : PrivacyPolicy.find(params[:id])
  end

  def create
    @policy = PrivacyPolicy.new(policy_params)

    if @policy.save
      redirect_to @policy, notice: 'Privacy policy published.'
    else
      flash.now[:alert] = @policy.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  private

  def preview_policy
    PrivacyPolicy.new(
                  version:  params[:version],
                  content:  params[:content]
                  )
  end

  def authorize_admin!
    redirect_to root_path, alert: 'Not authorized' unless current_user.is?('Admin')
  end

  def policy_params
    params.require(:privacy_policy).permit(:version, :content)
  end

end
