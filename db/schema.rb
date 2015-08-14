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

ActiveRecord::Schema.define(version: 20150814163212) do

  create_table "mlbgames", force: :cascade do |t|
    t.string   "away"
    t.string   "home"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
