class CreateApprenticeships < ActiveRecord::Migration
  def change
    create_table :apprenticeships do |t|
      t.integer :master
      t.integer :grasshopper
      t.datetime :start_date
      t.datetime :end_date
      t.boolean :status

      t.timestamps
    end
  end
end
