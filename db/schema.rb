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

ActiveRecord::Schema.define(version: 20150817192633) do

  create_table "mlbgames", force: :cascade do |t|
    t.string   "away"
    t.string   "home"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date     "date"
    t.float    "h_babip"
    t.float    "h_woba"
    t.float    "h_wrc"
    t.float    "h_bsr"
    t.float    "a_babip"
    t.float    "a_woba"
    t.float    "a_wrc"
    t.float    "a_bsr"
    t.string   "a_name"
    t.float    "a_sp_babip"
    t.float    "a_sp_xfip"
    t.float    "a_sp_tera"
    t.string   "h_name"
    t.float    "h_sp_babip"
    t.float    "h_sp_xfip"
    t.float    "h_sp_tera"
    t.float    "a_rp_babip"
    t.float    "a_rp_xfip"
    t.float    "a_rp_re24"
    t.float    "h_rp_babip"
    t.float    "h_rp_xfip"
    t.float    "h_rp_re24"
    t.float    "a_uzr150"
    t.float    "h_uzr150"
    t.float    "h_pred"
    t.float    "a_pred"
    t.integer  "h_actual"
    t.integer  "a_actual"
    t.integer  "correct"
  end

  create_table "nbagames", force: :cascade do |t|
    t.string   "home"
    t.string   "away"
    t.float    "homeWPct"
    t.float    "awayWPct"
    t.float    "homePPG"
    t.float    "awayPPG"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "nflgames", force: :cascade do |t|
    t.string   "home"
    t.string   "away"
    t.float    "homeWPct"
    t.float    "awayWPct"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "nhlgames", force: :cascade do |t|
    t.string   "home"
    t.string   "away"
    t.integer  "homeW"
    t.integer  "homeL"
    t.integer  "homeOTL"
    t.integer  "awayW"
    t.integer  "awayL"
    t.integer  "awayOTL"
    t.integer  "homeGF"
    t.integer  "homeGA"
    t.integer  "awayGF"
    t.integer  "awayGA"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
