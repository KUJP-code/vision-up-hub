# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_04_12_042428) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.integer "download_count", default: 0
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "class_teachers", force: :cascade do |t|
    t.bigint "class_id", null: false
    t.bigint "teacher_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["class_id"], name: "index_class_teachers_on_class_id"
    t.index ["teacher_id"], name: "index_class_teachers_on_teacher_id"
  end

  create_table "course_lessons", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.bigint "lesson_id", null: false
    t.integer "week", null: false
    t.integer "day", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_course_lessons_on_course_id"
    t.index ["lesson_id"], name: "index_course_lessons_on_lesson_id"
  end

  create_table "courses", force: :cascade do |t|
    t.string "title", null: false
    t.string "description", default: ""
    t.boolean "released", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lessons", force: :cascade do |t|
    t.jsonb "admin_approval", default: []
    t.jsonb "curriculum_approval", default: []
    t.string "goal", null: false
    t.string "internal_notes", default: ""
    t.integer "level", null: false
    t.boolean "released", default: false
    t.string "title", null: false
    t.string "type", null: false
    t.integer "creator_id"
    t.integer "assigned_editor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "add_difficulty", default: []
    t.jsonb "example_sentences", default: []
    t.jsonb "extra_fun", default: []
    t.jsonb "instructions", default: []
    t.jsonb "large_groups", default: []
    t.jsonb "links", default: {}
    t.jsonb "materials", default: []
    t.jsonb "notes", default: []
    t.jsonb "outro", default: []
    t.integer "subtype"
    t.string "topic"
    t.jsonb "vocab", default: []
    t.jsonb "intro", default: []
    t.jsonb "lang_goals", default: {"sky"=>[], "land"=>[], "galaxy"=>[]}
    t.string "interesting_fact"
    t.integer "status"
    t.integer "changed_lesson_id"
    t.index ["assigned_editor_id"], name: "index_lessons_on_assigned_editor_id"
    t.index ["creator_id"], name: "index_lessons_on_creator_id"
  end

  create_table "managements", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.bigint "school_manager_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_managements_on_school_id"
    t.index ["school_manager_id"], name: "index_managements_on_school_manager_id"
  end

  create_table "organisations", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "phone", null: false
    t.string "notes", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_organisations_on_email", unique: true
    t.index ["name"], name: "index_organisations_on_name", unique: true
    t.index ["phone"], name: "index_organisations_on_phone", unique: true
  end

  create_table "plans", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "student_limit"
    t.date "start"
    t.date "finish_date"
    t.integer "total_cost"
    t.integer "months_paid"
    t.bigint "course_id", null: false
    t.bigint "organisation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_plans_on_course_id"
    t.index ["organisation_id"], name: "index_plans_on_organisation_id"
  end

  create_table "school_classes", force: :cascade do |t|
    t.string "name"
    t.bigint "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "students_count"
    t.index ["school_id"], name: "index_school_classes_on_school_id"
  end

  create_table "school_teachers", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.bigint "teacher_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_school_teachers_on_school_id"
    t.index ["teacher_id"], name: "index_school_teachers_on_teacher_id"
  end

  create_table "schools", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "organisation_id", null: false
    t.integer "students_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organisation_id"], name: "index_schools_on_organisation_id"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.string "concurrency_key", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "student_classes", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "class_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["class_id"], name: "index_student_classes_on_class_id"
    t.index ["student_id"], name: "index_student_classes_on_student_id"
  end

  create_table "students", force: :cascade do |t|
    t.jsonb "comments"
    t.integer "level"
    t.string "name"
    t.string "student_id"
    t.bigint "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "parent_id"
    t.date "start_date"
    t.date "quit_date"
    t.date "birthday"
    t.index ["parent_id"], name: "index_students_on_parent_id"
    t.index ["school_id"], name: "index_students_on_school_id"
    t.index ["student_id", "school_id"], name: "index_students_on_student_id_and_school_id", unique: true
  end

  create_table "support_messages", force: :cascade do |t|
    t.string "message"
    t.bigint "user_id"
    t.bigint "support_request_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["support_request_id"], name: "index_support_messages_on_support_request_id"
    t.index ["user_id"], name: "index_support_messages_on_user_id"
  end

  create_table "support_requests", force: :cascade do |t|
    t.integer "category"
    t.string "description"
    t.string "internal_notes"
    t.datetime "resolved_at"
    t.integer "resolved_by"
    t.jsonb "seen_by", default: []
    t.string "subject"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_support_requests_on_user_id"
  end

  create_table "test_results", force: :cascade do |t|
    t.integer "total_percent", null: false
    t.integer "write_percent"
    t.integer "read_percent"
    t.integer "listen_percent"
    t.integer "speak_percent"
    t.integer "prev_level", null: false
    t.integer "new_level", null: false
    t.jsonb "answers", default: {"reading"=>[], "writing"=>[], "speaking"=>[], "listening"=>[]}
    t.bigint "test_id", null: false
    t.bigint "student_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reason"
    t.index ["student_id"], name: "index_test_results_on_student_id"
    t.index ["test_id"], name: "index_test_results_on_test_id"
  end

  create_table "tests", force: :cascade do |t|
    t.string "name"
    t.integer "level"
    t.jsonb "questions", default: {}
    t.jsonb "thresholds", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "type", default: "Parent"
    t.bigint "organisation_id", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "extra_emails", default: []
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organisation_id"], name: "index_users_on_organisation_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "class_teachers", "school_classes", column: "class_id"
  add_foreign_key "class_teachers", "users", column: "teacher_id"
  add_foreign_key "course_lessons", "courses"
  add_foreign_key "course_lessons", "lessons"
  add_foreign_key "lessons", "lessons", column: "changed_lesson_id"
  add_foreign_key "lessons", "users", column: "assigned_editor_id"
  add_foreign_key "lessons", "users", column: "creator_id"
  add_foreign_key "managements", "schools"
  add_foreign_key "managements", "users", column: "school_manager_id"
  add_foreign_key "plans", "courses"
  add_foreign_key "plans", "organisations"
  add_foreign_key "school_classes", "schools"
  add_foreign_key "school_teachers", "schools"
  add_foreign_key "school_teachers", "users", column: "teacher_id"
  add_foreign_key "schools", "organisations"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "student_classes", "school_classes", column: "class_id"
  add_foreign_key "student_classes", "students"
  add_foreign_key "students", "schools"
  add_foreign_key "students", "users", column: "parent_id"
  add_foreign_key "support_messages", "support_requests"
  add_foreign_key "support_messages", "users"
  add_foreign_key "support_requests", "users"
  add_foreign_key "test_results", "students"
  add_foreign_key "test_results", "tests"
  add_foreign_key "users", "organisations"
end
