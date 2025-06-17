class CreateSimulationLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :simulation_logs do |t|
      t.json :params
      t.json :results

      t.timestamps
    end
  end
end
