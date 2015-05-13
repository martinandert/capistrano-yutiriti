module Capistrano
  module Yutiriti
    module DSL
      def config_path
        shared_path.join("config")
      end

      def dot_env_path
        shared_path.join(".env")
      end

      def set_config_vars(vars = {})
        return if vars.empty?

        execute :mkdir, "-p", config_path

        within config_path do
          vars.each do |key, value|
            execute :echo, value, ">", key
            execute :chmod, "600", key
          end
        end

        update_dot_env
      end

      def unset_config_vars(keys)
        return if keys.empty?

        execute :mkdir, "-p", config_path

        within config_path do
          execute :rm, "-f", *keys
        end

        update_dot_env
      end

      def update_dot_env
        execute <<-EOCOMMAND
          config_path=#{config_path}
          dot_env_path=#{dot_env_path}
          rm -f $dot_env_path
          mkdir -p $config_path
          for e in $(ls $config_path)
            do echo "$e=$(cat $config_path/$e)" >> $dot_env_path
          done
          chmod 600 $dot_env_path
        EOCOMMAND
      end
    end
  end
end

include Capistrano::Yutiriti::DSL
