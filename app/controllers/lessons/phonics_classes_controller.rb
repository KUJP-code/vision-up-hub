# frozen_string_literal: true

class PhonicsClassesController < LessonsController
  def index
    @lessons = policy_scope(PhonicsClass.all)
  end

  def create
    @lesson = authorize Lesson.new(phonics_class_params)

    if @lesson.save!
      redirect_to lesson_url(@lesson),
                  notice: "Phonics Class successfully created! #{GUIDE_DELAY}"
    else
      set_courses
      render 'lessons/new',
             status: :unprocessable_entity,
             alert: 'Phonics Class could not be created'
    end
  end

  def update
    if @lesson.update(phonics_class_params)
      redirect_to lesson_url(@lesson),
                  notice: "Phonics Class successfully updated. #{GUIDE_DELAY}"
    else
      set_courses
      render 'lessons/edit',
             status: :unprocessable_entity,
             alert: 'Phonics Class could not be updated'
    end
  end

  private

  def phonics_class_params
    pc_params = %i[add_difficulty extra_fun instructions links materials notes title type]
    params.require(:phonics_class).permit(lesson_params + pc_params)
  end
end
