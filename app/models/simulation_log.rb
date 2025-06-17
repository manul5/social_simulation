# app/models/simulation_log.rb
class SimulationLog < ApplicationRecord
  def params_human
    JSON.pretty_generate(params)
  end

  def results_human
    JSON.pretty_generate(results)
  end
end
