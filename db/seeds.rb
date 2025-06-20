require 'faker'

def chi_squared_test(observed, expected)
  observed.zip(expected).map { |o, e| (o - e)**2 / e.to_f }.sum
end

def chi_squared_biases(biases, bins = 10)
  # Discretiza biases en bins
  bin_edges = (-1..1).step(2.0 / bins).to_a
  counts = Array.new(bins, 0)
  biases.each do |b|
    idx = [ [ ((b + 1) / 2 * bins).floor, bins - 1 ].min, 0 ].max
    counts[idx] += 1
  end
  expected = [ biases.size / bins.to_f ] * bins
  chi2 = chi_squared_test(counts, expected)
  { chi2: chi2.round(2), observed: counts, expected: expected.map(&:round) }
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

# Generar 1000 valores de bias en [-1, 1] usando Metodo Congruencial Lineal
puts "👥 Creando 1000 usuarios..."
biases = mcl(Time.now.to_i, 1000).map { |n| (n * 2 - 1).round(2) } # Normaliza a [-1,1] se usa la formula (a + (b-a) * n)
users = 1000.times.map do |i|
  User.create!(
    name: Faker::Name.unique.name,
    bias: biases[i]
  )
end

# Crear 200 posts con is_fake aleatorio
puts "📝 Creando 200 publicaciones..."
# Genera 200 números pseudoaleatorios para is_fake
is_fake_values = mcl(Time.now.to_i + 1, 200) # Usa una semilla distinta a la de bias

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
chi2_biases = chi_squared_biases(biases)
chi2_is_fake = chi_squared_is_fake(is_fake_values)

# Guarda los resultados en variables globales para acceder desde el controlador
$chi2_results = {
  biases: chi2_biases,
  is_fake: chi2_is_fake
}

puts "Prueba chi-cuadrada biases: #{chi2_biases}"
puts "Prueba chi-cuadrada is_fake: #{chi2_is_fake}"

puts "✅ ¡Datos creados!"
puts "Usuarios: #{User.count} (Sesgo promedio: #{User.average(:bias).round(2)})"
puts "Posts: #{Post.count} (#{Post.where(is_fake: true).count} fake news)"
