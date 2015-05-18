namespace :buildpack do
  desc "Compile the buildpack"
  task :compile do
    on roles :app do
      url, branch = fetch(:buildpack_url).split('#')
      next unless url

      bp_dir = capture("mktemp -t buildpackXXXXX").chomp
      execute "rm -rf #{bp_dir}"

      if url =~ /\.tgz$/
        execute "mkdir -p #{bp_dir}"
        execute "curl -s #{url} | tar xvz -C #{bp_dir} >/dev/null 2>&1"
      else
        execute "git clone #{url} #{bp_dir} >/dev/null 2>&1"

        within bp_dir do
          if File.exist? ".gitmodules"
            execute :git, "submodule update --init --recursive"
          end

          if branch
            execute :git, "checkout", branch, "> /dev/null 2>&1"
          end
        end
      end

      within bp_dir do
        execute :chmod, "-f +x bin/{detect,compile} || true"

        execute :"bin/detect", release_path, "> /dev/null"
        execute :"bin/compile", release_path, shared_path.join("cache/build"), config_path
      end

      export_file = "#{bp_dir}/export"

      if test("[ -r #{export_file} ]")
        execute "source #{export_file}"

        exports = capture(:cat, export_file).split("\n").reject { |line| line =~ /^\s*$/ }.inject({}) do |memo, line|
          key, value = line.split("=", 2)
          key = key.strip.split(" ").last
          memo.merge key => value.strip
        end

        set_config_vars exports
      end
    end
  end

  after "deploy:updated", "buildpack:compile"
end

