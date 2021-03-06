# config valid only for current version of Capistrano
lock '3.3.3'

set :application, 'alice'
set :repo_url, 'git@github.com:CoralineAda/alice.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/home/coraline/alice/'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  run_locally do
    begin
      execute 'bundle exec rake commands:export'
    rescue
    end
  end

  before :starting, :ensure_user   do
    on roles(:app), in: :groups, limit: 3, wait: 10 do
      within release_path do
        begin
          execute :ruby, './alice.rb stop'
          execute :ruby, 'db/commands/import.rb'
        rescue
          p "*** No daemon running, continuing"
        end
      end
    end
  end

  after :finishing, :notify do
    on roles(:app), in: :groups, limit: 3, wait: 10 do
      within release_path do
        execute :cp, '/home/coraline/alice/common/mongoid.yml config/mongoid.yml'
        execute :cp, '/home/coraline/alice/common/.env .env'
        execute :bundle, "install --path /home/coraline/alice/common/vendor/bundle"
        execute "ln -nfs /home/coraline/alice/common/vendor #{current_path}/vendor"
        execute :ruby, 'alice.rb -dvs --name alice --log log/alice.log --timeout 1 start'
      end
    end
  end

end
