class Simulation
  def initialize(users_count = 50, posts_count = 30)
    @users = User.all.sample(users_count)
    @posts = Post.all.sample(posts_count)
    validate_data!
  end

  def run(steps = 10)
    steps.times { simulate_sharing_step }
    log_results
  end

  private

  def validate_data!
    raise "No hay suficientes usuarios" if @users.empty?
    raise "No hay suficientes posts" if @posts.empty?
  end

  def simulate_sharing_step
    @users.shuffle.each do |user|
      next unless rand < sharing_probability(user)

      post = select_post_for(user)
      next unless post

      Share.create!(user: user, post: post) if should_share?(user, post)
    end
  end

  def sharing_probability(user)
    # Más probabilidad para bias cercano a 0 (usuarios moderados)
    0.6 - (user.bias.abs * 0.3)
  end

  def select_post_for(user)
    # Usuarios moderados ven ambos tipos con más probabilidad
    misaligned_chance = 0.5 - (user.bias.abs * 0.4) # 50% para bias 0, 10% para extremos

    if rand < misaligned_chance
      candidate_posts = @posts # Puede ver cualquier post
    else
      candidate_posts = user.bias > 0 ? @posts.reject(&:is_fake) : @posts.select(&:is_fake)
    end
    candidate_posts.max_by { |p| p.viral_score * rand(0.7..1.4) }
  end

  def should_share?(user, post)
    bias_weight = 1.0 - user.bias.abs # Más peso a viralidad si bias es bajo
    bias_effect = user.bias * (post.is_fake ? -2.0 : 2.0) * user.bias.abs
    viral_effect = post.viral_score ** (1.0 + bias_weight)
    randomness = rand(-1.0..1.0) * bias_weight

    (bias_effect + viral_effect + randomness) > 1.2
  end

  def log_results
    cross_shares = Share.joins(:user, :post)
                       .where("(users.bias > 0 AND posts.is_fake = true) OR (users.bias < 0 AND posts.is_fake = false)")
                       .count

    puts "\n=== RESULTADOS SIMULACIÓN ==="
    puts "Total shares: #{Share.count}"
    puts "Shares cruzados: #{cross_shares} (#{(cross_shares.to_f/Share.count*100).round(1)}%)"

    # Estadísticas detalladas por rango de sesgo
    {
      "Fuerte negativo (-1.0 a -0.5)" => -1.0..-0.5,
      "Moderado negativo (-0.5 a 0)" => -0.5..0,
      "Moderado positivo (0 a 0.5)" => 0..0.5,
      "Fuerte positivo (0.5 a 1.0)" => 0.5..1.0
    }.each do |label, range|
      users = User.where(bias: range)
      shares = Share.joins(:user).where(users: { bias: range })
      cross = shares.joins(:post).where("posts.is_fake = #{range.begin > 0 ? 'true' : 'false'}")

      puts "\n#{label}:"
      puts "  Usuarios: #{users.count}"
      puts "  Shares: #{shares.count}"
      puts "  Shares cruzados: #{cross.count} (#{(cross.count.to_f/shares.count*100).round(1)}%)"
    end
  end
end
