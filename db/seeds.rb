require 'faker'

# Limpiar toda la data existente
puts "🧹 Limpiando base de datos..."
Share.delete_all
Post.delete_all
User.delete_all

# Crear usuarios con distribución de sesgos más realista
puts "👥 Creando 100 usuarios..."
users = 100.times.map do
  # Distribución más realista de sesgos (menos extremos)
  bias = if rand < 0.2
           rand(-1.0..-0.5)  # 20% sesgo negativo fuerte
  elsif rand < 0.4
           rand(-0.5..0)     # 20% sesgo negativo moderado
  elsif rand < 0.6
           rand(0..0.5)      # 20% sesgo positivo moderado
  elsif rand < 0.8
           rand(0.5..1.0)    # 20% sesgo positivo fuerte
  else
           rand(-0.3..0.3)   # 20% neutrales
  end.round(2)

  User.create!(
    name: Faker::Name.unique.name,
    bias: bias
  )
end

# Crear posts con distribución más balanceada
puts "📝 Creando 50 publicaciones..."
50.times do |i|
  is_fake = i.even?  # Alternar entre true/false para mejor distribución
  creator = users.sample

  Post.create!(
    content: Faker::Lorem.unique.sentence(word_count: 8),
    is_fake: is_fake,
    user: creator,  # Asociación directa
    created_at: rand(1..30).days.ago  # Variedad temporal
  )
end

puts "✅ ¡Datos creados!"
puts "Usuarios: #{User.count} (Sesgo promedio: #{User.average(:bias).round(2)})"
puts "Posts: #{Post.count} (#{Post.where(is_fake: true).count} fake news)"
