# frozen_string_literal: true

class SchoolManager < User
  include IpLockable, LessonConsumable

  VISIBLE_TYPES = %w[Parent Teacher].freeze

  has_many :test_visibility_overrides, dependent: :destroy,
                                       foreign_key: :user_id,
                                       inverse_of: :user
  has_many :override_tests, through: :test_visibility_overrides,
                            source: :test
  has_many :form_submissions, dependent: :restrict_with_error,
                              foreign_key: :staff_id,
                              inverse_of: :staff
  has_many :managements, dependent: :destroy
  accepts_nested_attributes_for :managements,
                                allow_destroy: true,
                                reject_if: :all_blank
  has_many :schools, through: :managements
  has_many :classes, through: :schools,
                     class_name: 'SchoolClass'
  has_many :students, through: :schools
  has_many :parents, through: :students
  has_many :test_results, through: :students
  has_many :teachers, through: :schools

  def available_tests(date = Time.zone.today)
    scoped_test_ids = super(date).select(:id)
    override_test_ids = test_visibility_overrides.select(:test_id)

    Test.where(id: scoped_test_ids)
        .or(Test.where(id: override_test_ids))
        .distinct
  end
end
