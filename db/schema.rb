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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130425212952) do

  create_table "documents", :force => true do |t|
    t.string   "document_id"
    t.string   "document_path"
    t.boolean  "folder_or_file"
    t.string   "document_name"
    t.string   "document_uploader"
    t.integer  "parent_dir"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "github_users", :force => true do |t|
    t.string   "username"
    t.string   "token"
    t.string   "user_id"
    t.string   "git_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "permissions", :force => true do |t|
    t.integer  "document_id"
    t.string   "user_id"
    t.string   "document_path"
    t.boolean  "p_update"
    t.boolean  "p_delete"
    t.boolean  "p_move"
    t.boolean  "p_share"
    t.boolean  "p_view"
    t.boolean  "p_upload"
    t.boolean  "p_create_folder"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "uid"
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "is_admin"
    t.string   "token"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
