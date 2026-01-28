# frozen_string_literal: true

class AdminsController < UsersController
  def show
    @assigned_lessons = @user.assigned_lessons
    @announcements = policy_scope(Announcement)
    @created_lessons = @user.created_lessons
    @writers = User.where(type: %w[Admin Writer]).pluck(:name, :id)
    @org_teachers = Organisation.all
                                .map { |org| { org:, teacher: org.teachers.first } }
                                .reject { |h| h[:teacher].nil? }
  end

  def new
    # KidsUP is org 1
    @user = authorize Admin.new(organisation_id: 1)
    @orgs = policy_scope(Organisation)
  end

  def create
    @orgs = policy_scope(Organisation)
    # KidsUP
    organisation_id = 1
    @user = authorize Admin.new(admin_params.merge(organisation_id:))

    if @user.save
      redirect_to organisation_admin_path(@user.organisation, @user),
                  notice: "#{@user.name} successfully created."
    else
      render :new, status: :unprocessable_entity,
                   alert: "Couldn't create admin"
    end
  end

  def update
    if @user.update(admin_params)
      redirect_to organisation_admin_path(@user.organisation, @user),
                  notice: "#{@user.name} successfully updated."
    else
      render :edit,
             status: :unprocessable_entity,
             alert: "Couldn't update admin"
    end
  end

  def destroy
    return redirect_to users_path, alert: 'Must have 1 admin' if Admin.count <= 1

    if @user.destroy
      redirect_to users_path, notice: "#{@user.name} successfully deleted."
    else
      redirect_to users_path, alert: "Couldn't delete admin"
    end
  end

  def change_password
    authorize :admin
    user = User.find_by(email: change_password_params[:email])
    if user.nil?
      redirect_to root_url, alert: 'No user found'
      return
    end
    unless allowed_password_reset_target?(user)
      redirect_to root_url, alert: 'Not authorized to change this password'
      return
    end
    if change_password_params[:new_password] != change_password_params[:confirm_new_password]
      redirect_to root_url,
                  alert: 'Passwords did not match'
      return
    end
    user.reset_password(change_password_params[:new_password], change_password_params[:confirm_new_password])
    redirect_to root_url, notice: 'Password successfully changed'
  end

  def new_password_change
    authorize :admin
  end

  def reassign_editor
    authorize :admin
    @new_editor = User.find(params[:new_editor_id])
    @old_editor = User.find(params[:old_editor_id])

    if Lesson.reassign_editor(@old_editor.id, @new_editor.id)
      redirect_to organisation_user_path(@old_editor.organisation, @new_editor),
                  notice: "Reassigned lessons from #{@old_editor.name} to #{@new_editor.name}"
    else
      redirect_to organisation_user_path(@old_editor.organisation, @old_editor),
                  alert: "Could not reassign lessons from #{@old_editor.name} to #{@new_editor.name}"
    end
  end

  private

  def change_password_params
    params.permit(:email, :new_password, :confirm_new_password)
  end

  def allowed_password_reset_target?(user)
    return true if super_admin?

    return !user.is?('Admin') if current_user.is?('Admin')

    return false unless current_user.is?('OrgAdmin')

    user.organisation_id == current_user.organisation_id &&
      !user.is?('Admin', 'OrgAdmin')
  end

  def super_admin?
    current_user.is?('Admin') && AdminPolicy::SPECIAL_ADMIN_IDS.include?(current_user.id)
  end

  def admin_params
    a_params = %i[]
    params.require(:admin).permit(user_params + a_params)
  end
end
