# frozen_string_literal: true

class SalesController < UsersController
  def show
    @announcements = policy_scope(Announcement)
  end

  def new
    @user = authorize Sales.new(organisation_id: params[:organisation_id])
    @orgs = policy_scope(Organisation)

  end

  def create
    @user = authorize Sales.new(sales_params)

    if @user.save
      redirect_to organisation_sale_path(@user.organisation, @user),
                  notice: t('create_success')
    else
      render :new,
             status: :unprocessable_entity,
             alert: t('create_failure')
    end
  end

  def update
    if @user.update(sales_params)
      redirect_to organisation_sale_path(@user.organisation, @user),
                  notice: t('update_success')
    else
      render :edit,
             status: :unprocessable_entity,
             alert: t('update_failure')
    end
  end

  private

  def sales_params
    s_params = %i[]
    params.require(:sales).permit(user_params + s_params)
  end

  def scoped_users
    super.where(type: 'Sales')
  end
end
