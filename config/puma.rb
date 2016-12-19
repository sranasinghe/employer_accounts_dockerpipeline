def env_or_default(name, default)
  from_env = (ENV[name] || '').strip
  if !from_env.empty?
    from_env
  else
    default
  end
end

worker_timeout 3600 if ENV['RAILS_ENV'] == 'development'
threads env_or_default('PUMA_THREADS_MIN', 1), env_or_default('PUMA_THREADS_MAX', 16)
workers env_or_default('PUMA_WORKERS', 4)
preload_app!

on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.connection.reconnect!
  end
end
