class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :service_id
      t.date :start
      t.date :end
      t.boolean :monday
      t.boolean :tuesday
      t.boolean :wednesday
      t.boolean :thursday
      t.boolean :friday
      t.boolean :saturday
      t.boolean :sunday
      t.timestamps
    end
  end
end
