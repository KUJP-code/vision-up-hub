class PrivacyPolicyAcceptancesController < ApplicationController
  # skip_before_action :ensure_privacy_policy_accepted
  before_action :authorize_admin!, only: :index

  def index
    @acceptances = PrivacyPolicyAcceptance
                   .includes(:user, :privacy_policy)
                   .order(accepted_at: :desc)
  end

  def new
    @policy = PrivacyPolicy.find(PrivacyPolicy.latest_id)
  end

  def create
    pp_params = params.require(:privacy_policy_acceptance).permit(:accepted)

    acceptance = current_user
                 .privacy_policy_acceptances
                 .build(privacy_policy_id: PrivacyPolicy.latest_id)

    acceptance.accepted_at = Time.current if pp_params[:accepted] == '1'

    if acceptance.save
      redirect_to stored_location_for(:user) || root_path,
                  notice: t('privacy_policy_acceptances.accepted')
    else
      @policy = PrivacyPolicy.find(PrivacyPolicy.latest_id)
      flash.now[:alert] = t('privacy_policy_acceptances.accept_failed',
                            default: 'Please tick the box.')
      render :new, status: :unprocessable_entity
    end
  end

  private

  def authorize_admin!
    redirect_to root_path, alert: 'Not authorized' unless current_user.is?('Admin')
  end
end
