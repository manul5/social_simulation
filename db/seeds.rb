require 'faker'

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
biases = mcl(Time.now.to_i, 1000).map { |n| (n * 2 - 1).round(2) } # Normaliza a [-1,1]

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

puts "✅ ¡Datos creados!"
puts "Usuarios: #{User.count} (Sesgo promedio: #{User.average(:bias).round(2)})"
puts "Posts: #{Post.count} (#{Post.where(is_fake: true).count} fake news)"
