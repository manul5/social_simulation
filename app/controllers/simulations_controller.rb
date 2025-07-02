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

  chi2 = $chi2_results
  chi2_critical_is_fake = 3.84

  flash[:notice] = "¡Datos creados! Posts: #{Post.count} (#{Post.where(is_fake: true).count} fake news)"
  flash[:chi2] = "Chi² posteos falsos: observado=#{chi2[:is_fake][:chi2]}, tabla=#{chi2_critical_is_fake}, α=0.05. " \
                 "Resultado: #{chi2[:is_fake][:chi2] > chi2_critical_is_fake ? 'Se rechaza H₀' : 'Se acepta H₀'}"

  redirect_to simulations_path
  end
  def download_excel
    @top_users = User.joins(shares: :post)
                     .select('users.id, users.name, users.bias, users.classification,
                              COUNT(shares.id) as shares_count,
                              SUM(CASE WHEN posts.is_fake = false THEN 1 ELSE 0 END) as real_shares,
                              SUM(CASE WHEN posts.is_fake = true THEN 1 ELSE 0 END) as fake_shares')
                     .group("users.id, users.name, users.bias, users.classification")
                     .order("shares_count DESC")

    respond_to do |format|
      format.xlsx {
        response.headers["Content-Disposition"] = 'attachment; filename="tabla_compartidores.xlsx"'
      }
    end
  end
end
