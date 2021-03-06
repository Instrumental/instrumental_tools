require 'capistrano'

if Capistrano::Configuration.instance
  Capistrano::Configuration.instance.load do
    namespace :instrumental do
      desc "restart daemonized server; also starts up if not running"
      task :restart_instrument_server do
        run "cd #{current_path} && bundle exec instrument_server -k #{instrumental_key} -d restart"
      end
    end

    after "deploy", "instrumental:restart_instrument_server"
    after "deploy:migrations", "instrumental:restart_instrument_server"
  end
end
