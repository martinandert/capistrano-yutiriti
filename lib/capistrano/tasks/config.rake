desc "Display the config vars"
task :config do
  path = config_path

  on roles :app do
    vars = capture(<<-EOCOMMAND)
      config_path=#{path}
      if [ -d "$config_path" ]
        then for e in $(ls $config_path)
          do echo "$e: $(cat $config_path/$e)"
        done
      fi
    EOCOMMAND
  end
end

namespace :config do
  def ignore(*args)
    args.each do |arg|
      Rake::Task.define_task arg.to_sym
    end
  end

  desc "Import the config vars"
  task :import do
    on roles :app do
      vars = capture(:cat, dot_env_path).split("\n").reject { |line| line =~ /^\s*$/ }.map { |var| var.split("=", 2) }.inject({}) do |memo, (key, value)|
        memo.merge key => value
      end

      execute :rm, "-rf", config_path
      set_config_vars vars
    end
  end

  desc "Export the config vars"
  task :export do
    path = config_path

    on roles :app do
      execute <<-EOCOMMAND
        config_path=#{path}
        if [ -d "$config_path" ]
          then for e in $(ls $config_path)
            do export "$e=$(cat $config_path/$e)"
          done
        fi
      EOCOMMAND
    end
  end

  desc "Display a config value for KEY"
  task :get do
    on roles :app do
      keys = ARGV[2..-1]

      case keys.size
      when 0
        error "Usage: cap STAGE config:get KEY"
        error "Must specify KEY."
      when 1
        key = keys.first

        within config_path do
          info capture(:cat, key)
        end

        ignore key
      else
        keys[1..-1].each do |key|
          error "Invalid argument: \"#{key}\""
        end

        ignore(*keys)
      end
    end
  end

  desc "Set one or more config vars KEY1=VALUE1 [KEY2=VALUE2 ...]"
  task :set do
    on roles :app do
      vars = ARGV[2..-1].map { |var| var.split("=", 2) }

      if vars.empty? || vars.any? { |var| var.size != 2 }
        error "Usage: cap STAGE config:set KEY1=VALUE1 [KEY2=VALUE2 ...]"
        error "Must specify KEY and VALUE to set."

        ignore(*vars.select { |var| var.size == 1 }.map(&:first))
      else
        vars = vars.inject({}) do |memo, (key, value)|
          info "#{key}: #{value}"
          memo.merge key => value
        end

        set_config_vars vars
      end
    end
  end

  desc "Unset one or more config vars KEY1 [KEY2 ...]"
  task :unset do
    on roles :app do
      keys = ARGV[2..-1]

      unset_config_vars keys

      ignore(*keys)
    end
  end
end

set :linked_files, fetch(:linked_files, []).push(".env")
