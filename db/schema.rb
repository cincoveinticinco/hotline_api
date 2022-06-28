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

ActiveRecord::Schema.define(version: 2022_06_24_155014) do

  create_table "answers", charset: "latin1", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.bigint "report_id", null: false
    t.string "a_txt"
    t.boolean "a_yes_or_no"
    t.bigint "q_option_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["q_option_id"], name: "index_answers_on_q_option_id"
    t.index ["question_id"], name: "index_answers_on_question_id"
    t.index ["report_id"], name: "index_answers_on_report_id"
  end

  create_table "centers", charset: "latin1", force: :cascade do |t|
    t.string "center_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "locations", charset: "latin1", force: :cascade do |t|
    t.string "location_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "project_aliases", charset: "latin1", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "p_alias"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["project_id"], name: "index_project_aliases_on_project_id"
  end

  create_table "projects", charset: "latin1", force: :cascade do |t|
    t.string "p_name"
    t.integer "p_season"
    t.bigint "center_id", null: false
    t.bigint "location_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["center_id"], name: "index_projects_on_center_id"
    t.index ["location_id"], name: "index_projects_on_location_id"
  end

  create_table "q_options", charset: "latin1", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.string "q_option_title"
    t.string "q_option_txt"
    t.integer "q_option_order"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["question_id"], name: "index_q_options_on_question_id"
  end

  create_table "q_types", charset: "latin1", force: :cascade do |t|
    t.string "q_type_txt"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "questions", charset: "latin1", force: :cascade do |t|
    t.bigint "r_type_id", null: false
    t.bigint "q_type_id", null: false
    t.string "q_title"
    t.string "q_txt"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["q_type_id"], name: "index_questions_on_q_type_id"
    t.index ["r_type_id"], name: "index_questions_on_r_type_id"
  end

  create_table "r_methods", charset: "latin1", force: :cascade do |t|
    t.string "r_method_txt"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "r_replies", charset: "latin1", force: :cascade do |t|
    t.bigint "report_id", null: false
    t.bigint "user_id", null: false
    t.string "reply_txt"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["report_id"], name: "index_r_replies_on_report_id"
    t.index ["user_id"], name: "index_r_replies_on_user_id"
  end

  create_table "r_statuses", charset: "latin1", force: :cascade do |t|
    t.string "r_status_txt"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "r_types", charset: "latin1", force: :cascade do |t|
    t.string "r_type_txt"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "reports", charset: "latin1", force: :cascade do |t|
    t.bigint "r_type_id", null: false
    t.bigint "r_method_id", null: false
    t.bigint "r_status_id", null: false
    t.bigint "project_id"
    t.string "r_email"
    t.string "r_reference"
    t.string "password_digest"
    t.datetime "token_last_update"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["project_id"], name: "index_reports_on_project_id"
    t.index ["r_method_id"], name: "index_reports_on_r_method_id"
    t.index ["r_status_id"], name: "index_reports_on_r_status_id"
    t.index ["r_type_id"], name: "index_reports_on_r_type_id"
  end

  create_table "user_has_projects", charset: "latin1", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "project_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["project_id"], name: "index_user_has_projects_on_project_id"
    t.index ["user_id"], name: "index_user_has_projects_on_user_id"
  end

  create_table "user_types", charset: "latin1", force: :cascade do |t|
    t.string "user_type_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", charset: "latin1", force: :cascade do |t|
    t.bigint "user_type_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "token"
    t.datetime "token_last_update"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_type_id"], name: "index_users_on_user_type_id"
  end

  add_foreign_key "answers", "q_options"
  add_foreign_key "answers", "questions"
  add_foreign_key "answers", "reports"
  add_foreign_key "project_aliases", "projects"
  add_foreign_key "projects", "centers"
  add_foreign_key "projects", "locations"
  add_foreign_key "q_options", "questions"
  add_foreign_key "questions", "q_types"
  add_foreign_key "questions", "r_types"
  add_foreign_key "r_replies", "reports"
  add_foreign_key "r_replies", "users"
  add_foreign_key "reports", "projects"
  add_foreign_key "reports", "r_methods"
  add_foreign_key "reports", "r_statuses"
  add_foreign_key "reports", "r_types"
  add_foreign_key "user_has_projects", "projects"
  add_foreign_key "user_has_projects", "users"
  add_foreign_key "users", "user_types"
end
