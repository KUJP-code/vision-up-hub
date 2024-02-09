# frozen_string_literal: true

class WritersController < UsersController
  def show
    @assigned_lessons = @user.assigned_lessons
    @created_lessons = @user.created_lessons
    @writers = User.where(type: %w[Admin Writer]).pluck(:name, :id) if current_user.is?('Admin')
  end

  def new
    @user = authorize Writer.new(organisation_id: params[:organisation_id])
  end

  def create
    @user = authorize Writer.new(writer_params)

    if @user.save
      redirect_to organisation_writer_path(@user.organisation, @user),
                  notice: "#{@user.name} successfully created."
    else
      render :new,
             status: :unprocessable_entity,
             alert: "Couldn't create writer"
    end
  end

  def update
    if @user.update(writer_params)
      redirect_to organisation_writer_path(@user.organisation, @user),
                  notice: "#{@user.name} successfully updated."
    else
      render :edit,
             status: :unprocessable_entity,
             alert: "Couldn't update writer"
    end
  end

  private

  def scoped_users
    super.where(type: 'Writer')
  end

  def writer_params
    w_params = %i[]
    params.require(:writer).permit(user_params + w_params)
  end
end
