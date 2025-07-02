require 'csv'

CSV.open('db/users_biases.csv', 'w') do |csv|
  csv << ['bias']
  1000.times do
    csv << [((rand * 2) - 1).round(2)]
  end
end