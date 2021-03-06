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

ActiveRecord::Schema.define(version: 20140806143806) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "services", force: true do |t|
    t.string  "service_id"
    t.date    "start"
    t.date    "endd"
    t.boolean "monday"
    t.boolean "tuesday"
    t.boolean "wednesday"
    t.boolean "thursday"
    t.boolean "friday"
    t.boolean "saturday"
    t.boolean "sunday"
  end

  create_table "stations", force: true do |t|
    t.integer "real_id"
    t.string  "name"
    t.float   "lat"
    t.float   "lon"
  end

  add_index "stations", ["lat", "lon"], name: "index_stations_on_lat_and_lon", using: :btree

  create_table "stop_times", force: true do |t|
    t.integer "station_id"
    t.string  "trip_id"
    t.string  "arrival"
    t.string  "departure"
  end

  add_index "stop_times", ["station_id", "arrival"], name: "index_stop_times_on_station_id_and_arrival", using: :btree

  create_table "trips", force: true do |t|
    t.string "trip_id"
    t.string "service_id"
    t.string "headsign"
  end

  add_index "trips", ["trip_id"], name: "index_trips_on_trip_id", using: :btree

end
