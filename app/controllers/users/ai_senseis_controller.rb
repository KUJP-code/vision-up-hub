# frozen_string_literal: true

class AiSenseisController < UsersController
  def new
    @user = authorize AiSensei.new(organisation_id: params[:organisation_id])
    @orgs = policy_scope(Organisation)
  end

  def create
    @user = authorize AiSensei.new(ai_sensei_params)
    @orgs = policy_scope(Organisation)
    if @user.save
      redirect_to edit_organisation_ai_sensei_path(@user.organisation, @user), notice: 'ai-sensei account created.'
    else
      render 'users/new', status: :unprocessable_content
    end
  end

  def update
    if @user.update(ai_sensei_params)
      redirect_to edit_organisation_ai_sensei_path(@user.organisation, @user), notice: 'ai-sensei account updated.'
    else
      render 'users/edit', status: :unprocessable_content
    end
  end

  def destroy
    @user.destroy!
    redirect_to users_path, notice: 'ai-sensei account deleted.'
  end

  private

  def set_user
    @user = authorize AiSensei.find(params[:id])
  end

  def ai_sensei_params
    params.require(:ai_sensei).permit(user_params)
  end
end
