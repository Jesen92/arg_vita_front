# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160118170752) do

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "article_categories", force: :cascade do |t|
    t.integer  "article_id",  limit: 4
    t.integer  "category_id", limit: 4
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "article_complements", force: :cascade do |t|
    t.integer  "complement_id",     limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "single_article_id", limit: 4
  end

  create_table "articles", force: :cascade do |t|
    t.boolean  "raw",                                                    default: false
    t.string   "title",           limit: 255
    t.string   "title_eng",       limit: 255
    t.text     "description",     limit: 65535
    t.text     "description_eng", limit: 65535
    t.integer  "picture_id",      limit: 4
    t.integer  "category_id",     limit: 4
    t.integer  "material_id",     limit: 4
    t.integer  "subcategory_id",  limit: 4
    t.integer  "ssubcategory_id", limit: 4
    t.integer  "suppliers_code",  limit: 4
    t.string   "code",            limit: 255,                            default: " "
    t.decimal  "weight",                        precision: 10, scale: 2
    t.integer  "amount",          limit: 4
    t.integer  "warning",         limit: 4
    t.decimal  "cost",                          precision: 10, scale: 2, default: 0.0
    t.integer  "discount",        limit: 4,                              default: 0
    t.datetime "start_date"
    t.datetime "end_date"
    t.boolean  "for_sale",                                               default: false
    t.datetime "created_at",                                                             null: false
    t.datetime "updated_at",                                                             null: false
    t.boolean  "feature_product"
    t.boolean  "on_discount"
    t.integer  "counter",         limit: 4,                              default: 0
  end

  create_table "auctions", force: :cascade do |t|
    t.integer  "article_id",     limit: 4
    t.datetime "start_date"
    t.datetime "end_date"
    t.decimal  "starting_price",           precision: 10
    t.decimal  "highest_bid",              precision: 10
    t.integer  "user_id",        limit: 4
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "complement_id",  limit: 4
  end

  create_table "carts_articles", force: :cascade do |t|
    t.integer  "shopping_cart_id",  limit: 4
    t.integer  "single_article_id", limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string   "title",               limit: 255
    t.string   "title_eng",           limit: 255
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "parent_id",           limit: 4
    t.integer  "lft",                 limit: 4
    t.integer  "rgt",                 limit: 4
    t.string   "avatar_file_name",    limit: 255
    t.string   "avatar_content_type", limit: 255
    t.integer  "avatar_file_size",    limit: 4
    t.datetime "avatar_updated_at"
  end

  create_table "category_materials", force: :cascade do |t|
    t.integer  "category_id", limit: 4
    t.integer  "material_id", limit: 4
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "category_subcategories", force: :cascade do |t|
    t.integer  "category_id",    limit: 4
    t.integer  "subcategory_id", limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "colors", force: :cascade do |t|
    t.string   "title",               limit: 255
    t.string   "title_eng",           limit: 255
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "avatar_file_name",    limit: 255
    t.string   "avatar_content_type", limit: 255
    t.integer  "avatar_file_size",    limit: 4
    t.datetime "avatar_updated_at"
  end

  create_table "complements", force: :cascade do |t|
    t.string   "title",           limit: 255
    t.string   "title_eng",       limit: 255
    t.text     "description",     limit: 65535
    t.text     "description_eng", limit: 65535
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "discount",        limit: 4
    t.boolean  "on_discount"
    t.datetime "start_date"
    t.datetime "end_date"
    t.boolean  "for_sale"
    t.decimal  "cost",                          precision: 10
    t.integer  "picture_id",      limit: 4
  end

  create_table "coupons", force: :cascade do |t|
    t.string   "code",       limit: 255
    t.integer  "discount",   limit: 4
    t.integer  "article_id", limit: 4
    t.boolean  "used"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "impressions", force: :cascade do |t|
    t.string   "impressionable_type", limit: 255
    t.integer  "impressionable_id",   limit: 4
    t.integer  "user_id",             limit: 4
    t.string   "controller_name",     limit: 255
    t.string   "action_name",         limit: 255
    t.string   "view_name",           limit: 255
    t.string   "request_hash",        limit: 255
    t.string   "ip_address",          limit: 255
    t.string   "session_hash",        limit: 255
    t.text     "message",             limit: 65535
    t.text     "referrer",            limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "impressions", ["controller_name", "action_name", "ip_address"], name: "controlleraction_ip_index", using: :btree
  add_index "impressions", ["controller_name", "action_name", "request_hash"], name: "controlleraction_request_index", using: :btree
  add_index "impressions", ["controller_name", "action_name", "session_hash"], name: "controlleraction_session_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "ip_address"], name: "poly_ip_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "request_hash"], name: "poly_request_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "session_hash"], name: "poly_session_index", using: :btree
  add_index "impressions", ["impressionable_type", "message", "impressionable_id"], name: "impressionable_type_message_index", length: {"impressionable_type"=>nil, "message"=>255, "impressionable_id"=>nil}, using: :btree
  add_index "impressions", ["user_id"], name: "index_impressions_on_user_id", using: :btree

  create_table "materials", force: :cascade do |t|
    t.string   "title",               limit: 255
    t.string   "title_eng",           limit: 255
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "avatar_file_name",    limit: 255
    t.string   "avatar_content_type", limit: 255
    t.integer  "avatar_file_size",    limit: 4
    t.datetime "avatar_updated_at"
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "shopping_cart_id", limit: 4
    t.string   "ip_address",       limit: 255
    t.string   "card_type",        limit: 255
    t.date     "card_expires_on"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "past_purchases", force: :cascade do |t|
    t.integer  "user_id",           limit: 4
    t.integer  "single_article_id", limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "pictures", force: :cascade do |t|
    t.integer  "article_id",         limit: 4
    t.integer  "single_article_id",  limit: 4
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.datetime "image_updated_at"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "complement_id",      limit: 4
  end

  create_table "shopping_carts", force: :cascade do |t|
    t.decimal  "current_cost",           precision: 10
    t.integer  "user_id",      limit: 4
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "single_articles", force: :cascade do |t|
    t.integer  "article_id", limit: 4
    t.string   "title",      limit: 255
    t.string   "size",       limit: 255
    t.string   "code",       limit: 255
    t.integer  "color_id",   limit: 4
    t.integer  "amount",     limit: 4
    t.integer  "warning",    limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "ssubcategories", force: :cascade do |t|
    t.string   "title",               limit: 255
    t.string   "title_eng",           limit: 255
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "avatar_file_name",    limit: 255
    t.string   "avatar_content_type", limit: 255
    t.integer  "avatar_file_size",    limit: 4
    t.datetime "avatar_updated_at"
  end

  create_table "ssubcategory_subcategories", force: :cascade do |t|
    t.integer  "ssubcategory_id", limit: 4
    t.integer  "subcategory_id",  limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "subcategories", force: :cascade do |t|
    t.string   "title",               limit: 255
    t.string   "title_eng",           limit: 255
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "avatar_file_name",    limit: 255
    t.string   "avatar_content_type", limit: 255
    t.integer  "avatar_file_size",    limit: 4
    t.datetime "avatar_updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",                   limit: 255,                default: "", null: false
    t.date     "date_of_birth"
    t.string   "state",                  limit: 255,                default: "", null: false
    t.string   "city",                   limit: 255,                default: "", null: false
    t.string   "address",                limit: 255,                default: "", null: false
    t.string   "postcode",               limit: 255,                default: "", null: false
    t.string   "phone",                  limit: 255,                default: "", null: false
    t.string   "email",                  limit: 255,                default: "", null: false
    t.string   "encrypted_password",     limit: 255,                default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,                  default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.decimal  "purchase_sum",                       precision: 10
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
