class SimulationsController < ApplicationController
  def index
    # Estadísticas básicas
    @stats = {
      total_shares: Share.count,
      real_shares: Share.joins(:post).where(posts: { is_fake: false }).count,
      fake_shares: Share.joins(:post).where(posts: { is_fake: true }).count,
      total_users: User.count,
      total_posts: Post.count
    }

    # Top usuarios sin usar CASE WHEN que puede causar problemas
    @top_users = User.joins(shares: :post)
                     .select('users.id, users.name, users.bias,
                             COUNT(shares.id) as shares_count,
                             SUM(CASE WHEN posts.is_fake = false THEN 1 ELSE 0 END) as real_shares,
                             SUM(CASE WHEN posts.is_fake = true THEN 1 ELSE 0 END) as fake_shares')
                     .group("users.id, users.name, users.bias")
                     .order("shares_count DESC")
                     .limit(10)

    # Datos de depuración (solo si existen los modelos)
    @debug_info = {}
    if defined?(SimulationLog)
      @debug_info[:last_simulation] = SimulationLog.last
    end
    @debug_info[:shares_sample] = Share.last(5)
    @debug_info[:users_sample] = User.last(5)
  end

  def run
    users = params[:users_count].to_i.clamp(10, 1000)
    posts = params[:posts_count].to_i.clamp(5, 200)
    steps = params[:steps].to_i.clamp(1, 30)

    simulation = Simulation.new(users, posts)
    simulation.run(steps)

    # Registrar simulación solo si existe el modelo
    if defined?(SimulationLog)
      SimulationLog.create(
        params: {
          users_count: users,
          posts_count: posts,
          steps: steps
        },
        results: {
          shares_created: Share.count,
          new_users: User.count,
          new_posts: Post.count
        }
      )
    end

    redirect_to simulations_path, notice: "Simulación completada."
  rescue => e
    redirect_to simulations_path, alert: "Error en simulación: #{e.message}"
  end

  def reset
    Share.delete_all
    redirect_to simulations_path, notice: "Datos de simulación reseteados"
  end

  def reset_and_seed
    Share.delete_all
    Post.delete_all
    User.delete_all

    load Rails.root.join("db/seeds.rb")

    # Calcula estadísticas después de ejecutar el seed
    users_count = User.count
    avg_bias = User.average(:bias).round(2)
    posts_count = Post.count
    fake_count = Post.where(is_fake: true).count

    flash[:notice] = "¡Datos creados! Usuarios: #{users_count} (Sesgo promedio: #{avg_bias}) | Posts: #{posts_count} (#{fake_count} fake news)"

    redirect_to simulations_path
  end

  def download_excel
    @top_users = User.joins(shares: :post)
                     .select('users.id, users.name, users.bias,
                              COUNT(shares.id) as shares_count,
                              SUM(CASE WHEN posts.is_fake = false THEN 1 ELSE 0 END) as real_shares,
                              SUM(CASE WHEN posts.is_fake = true THEN 1 ELSE 0 END) as fake_shares')
                     .group("users.id, users.name, users.bias")
                     .order("shares_count DESC")

    respond_to do |format|
      format.xlsx {
        response.headers["Content-Disposition"] = 'attachment; filename="tabla_compartidores.xlsx"'
      }
    end
  end
end
