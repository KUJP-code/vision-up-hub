class PrivacyPolicyAcceptancesController < ApplicationController
  skip_before_action :ensure_privacy_policy_accepted

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
                  notice: t('privacy.accepted', default: 'Thanks for accepting!')
    else
      @policy = PrivacyPolicy.find(PrivacyPolicy.latest_id)
      flash.now[:alert] = t('privacy.accept_failed',
                            default: 'Please tick the box.')
      render :new, status: :unprocessable_entity
    end
  end
end