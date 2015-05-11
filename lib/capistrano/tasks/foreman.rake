namespace :foreman do
  task :setup do
    invoke "foreman:export"
    invoke "foreman:start"
  end

  desc "Export the Procfile"
  task :export do
    on roles :app do
      options = {
        app: fetch(:application),
        log: File.join(shared_path, "log"),
      }.merge fetch(:foreman_options, {})

      execute :mkdir, "-p", options[:log]

      within release_path do
        sudo :foreman, "export", "upstart", "/etc/init", *options.map { |key, value| "--#{key}=\"#{value}\"" }
      end
    end
  end

  desc "Start the application services"
  task :start do
    on roles :app do
      sudo :start, fetch(:application)
    end
  end

  desc "Stop the application services"
  task :stop do
    on roles :app do
      sudo :stop, fetch(:application)
    end
  end

  desc "Restart the application services"
  task :restart do
    on roles :app do
      sudo :restart, fetch(:application)
    end
  end

  after "deploy:restart", "foreman:export"
  after "deploy:restart", "foreman:restart"
end
