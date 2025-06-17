class Simulation
  def initialize(users_count, posts_count)
    Share.delete_all
    @users = User.all.sample(users_count)
    @posts = Post.all.sample(posts_count)
    validate_data!
  end

  def run(steps)
    steps.times { simulate_sharing_step }
    log_results
  end

  private

  def validate_data!
    raise "No hay suficientes usuarios" if @users.empty?
    raise "No hay suficientes posts" if @posts.empty?
  end

  def simulate_sharing_step
    @users.each do |user|
      post = @posts.sample

      Share.create!(user: user, post: post) if should_share?(user, post)
    end
  end

  def should_share?(user, post)
    # Comparte solo si el post coincide con el sesgo, o si es neutral
    return true if user.bias.abs <= 0.2
    return true if user.bias > 0.2 && !post.is_fake
    return true if user.bias < -0.2 && post.is_fake
    false
  end

  def log_results
    puts "Total de shares creados: #{Share.count}"
  end
end
