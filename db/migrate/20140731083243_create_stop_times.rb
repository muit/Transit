class CreateStopTimes < ActiveRecord::Migration
  def change
    create_table :stop_times do |t|

      t.timestamps
    end
  end
end
