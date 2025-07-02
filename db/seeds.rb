require 'faker'
require 'csv'

def chi_squared_test(observed, expected)
  observed.zip(expected).map { |o, e| (o - e)**2 / e.to_f }.sum
end

def chi_squared_is_fake(is_fake_values)
  counts = [ is_fake_values.count { |v| v < 0.5 }, is_fake_values.count { |v| v >= 0.5 } ]
  expected = [ is_fake_values.size / 2.0, is_fake_values.size / 2.0 ]
  chi2 = chi_squared_test(counts, expected)
  { chi2: chi2.round(2), observed: counts, expected: expected.map(&:round) }
end

# Método Congruencial Lineal para generar números pseudoaleatorios normalizados en [0,1)
def mcl(seed, cantidad)
  a = 1664525
  b = 1013904223
  m = 2**32
  x = seed
  Array.new(cantidad) do
    x = (a * x + b) % m
    x.to_f / m
  end
end

# Limpiar toda la data existente
puts "🧹 Limpiando base de datos..."
Share.delete_all
Post.delete_all
User.delete_all

# Leer biases desde el CSV y crear usuarios
puts "👥 Creando 1000 usuarios desde CSV..."
biases = []
CSV.foreach(Rails.root.join('db', 'users_biases.csv'), headers: true) do |row|
  biases << row['bias_score'].to_f
end

users = biases.map do |bias|
  classification =
    if bias >= 0.5 && bias <= 1
      "Acertado"
    elsif bias >= 0 && bias < 0.5
      "Desconfiado"
    elsif bias >= -0.5 && bias < 0
      "Ingenuo"
    elsif bias <= -0.5 && bias >= -1
      "Confundido"
    else
      "Sin Clasificación"
    end

  User.create!(
    name: Faker::Name.unique.name,
    bias: bias,
    classification: classification
  )
end

# Crear 200 posts with is_fake aleatorio
puts "📝 Creando 200 publicaciones..."
# Genera 200 números pseudoaleatorios para is_fake
is_fake_values = mcl(Time.now.to_i, 200) 

200.times do |i|
  is_fake = is_fake_values[i] >= 0.5
  creator = users.sample

  Post.create!(
    content: Faker::Lorem.unique.sentence(word_count: 8),
    is_fake: is_fake,
    user: creator,
    created_at: rand(1..30).days.ago
  )
end

# Realiza las pruebas de chi-cuadrada
# chi2_biases = chi_squared_biases(biases)
chi2_is_fake = chi_squared_is_fake(is_fake_values)

# Guarda los resultados en variables globales para acceder desde el controlador
$chi2_results = {
  # biases: chi2_biases,
  is_fake: chi2_is_fake
}

puts "Prueba chi-cuadrada is_fake: #{chi2_is_fake}"

puts "✅ ¡Datos creados!"
puts "Posts: #{Post.count} (#{Post.where(is_fake: true).count} fake news)"
