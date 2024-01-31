# frozen_string_literal: true

class SalesController < UsersController
  def show; end

  def new
    @user = authorize Sales.new(organisation_id: params[:organisation_id])
  end

  def create
    @user = authorize Sales.new(sales_params)

    if @user.save
      redirect_to organisation_sale_path(@user.organisation, @user),
                  notice: "#{@user.name} successfully created."
    else
      render :new,
             status: :unprocessable_entity,
             alert: "Couldn't create sales staff"
    end
  end

  def update
    if @user.update(sales_params)
      redirect_to organisation_sale_path(@user.organisation, @user),
                  notice: "#{@user.name} successfully updated."
    else
      render :edit,
             status: :unprocessable_entity,
             alert: "Couldn't update sales staff"
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
