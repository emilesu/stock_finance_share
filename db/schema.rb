# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180517145819) do

  create_table "attentions", force: :cascade do |t|
    t.integer "user_id"
    t.integer "my_attention"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["my_attention"], name: "index_attentions_on_my_attention"
    t.index ["user_id"], name: "index_attentions_on_user_id"
  end

  create_table "courses", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "friendly_id"
    t.string "surface_img"
    t.index ["friendly_id"], name: "index_courses_on_friendly_id", unique: true
  end

  create_table "fans", force: :cascade do |t|
    t.integer "user_id"
    t.integer "my_fans"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["my_fans"], name: "index_fans_on_my_fans"
    t.index ["user_id"], name: "index_fans_on_user_id"
  end

  create_table "identifies", force: :cascade do |t|
    t.integer "user_id"
    t.string "provider"
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "likes", force: :cascade do |t|
    t.integer "user_id"
    t.integer "note_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["note_id"], name: "index_likes_on_note_id"
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "notes", force: :cascade do |t|
    t.integer "stock_id"
    t.integer "user_id"
    t.string "status", default: "公开"
    t.string "level", default: "近期关注"
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_notes_on_status"
    t.index ["stock_id"], name: "index_notes_on_stock_id"
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.string "course_id"
    t.string "title"
    t.text "description"
    t.string "section"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "draft"
    t.string "catalog"
    t.index ["course_id"], name: "index_posts_on_course_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_id"
    t.string "twitter_id"
    t.index ["twitter_id"], name: "index_reviews_on_twitter_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "settings", force: :cascade do |t|
    t.text "industry"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "version"
  end

  create_table "stocks", force: :cascade do |t|
    t.string "symbol"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "lrb"
    t.text "llb"
    t.text "zcb"
    t.string "industry"
    t.string "easy_symbol"
    t.string "main_business"
    t.string "company_url"
    t.string "regional"
    t.integer "version"
    t.datetime "time_to_market"
    t.string "pinyin"
    t.text "dividends"
    t.text "static_data_10"
    t.text "static_data_5"
    t.text "static_data_2"
    t.index ["easy_symbol"], name: "index_stocks_on_easy_symbol", unique: true
    t.index ["industry"], name: "index_stocks_on_industry"
    t.index ["symbol"], name: "index_stocks_on_symbol", unique: true
  end

  create_table "twitters", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "公开"
    t.string "user_id"
    t.index ["status"], name: "index_twitters_on_status"
    t.index ["user_id"], name: "index_twitters_on_user_id"
  end

  create_table "users", force: :cascade do |t|
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "nonmember"
    t.string "time_range", default: "all_years"
    t.string "avatar"
    t.string "username"
    t.string "motto"
    t.string "openid"
    t.datetime "join_time"
    t.datetime "end_time"
    t.integer "nper"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["openid"], name: "index_users_on_openid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

end
