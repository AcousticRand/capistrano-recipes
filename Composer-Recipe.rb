namespace :composer do

  _cset(:composer_bin) { false }
  _cset(:php_bin) { "php" }
  _cset(:composer_options) { "--no-scripts --verbose --prefer-dist --no-dev" }

  desc "Ensure the latest Composer version is available - Gets composer and installs it or just update"
  task :get, :roles => :app, :except => { :no_release => true } do
    if 'true' == capture("if [ -e #{previous_release}/composer.phar ]; then echo 'true'; fi").strip
      run "#{try_sudo} sh -c 'cp #{previous_release}/composer.phar #{latest_release}/'"
    end

    if 'true' == capture("if [ -e #{latest_release}/composer.phar ]; then echo 'true'; fi").strip
      run "#{try_sudo} sh -c 'cd #{latest_release} && #{php_bin} composer.phar self-update'"
    else
      run "#{try_sudo} sh -c 'cd #{latest_release} && curl -s http://getcomposer.org/installer | #{php_bin}'"
    end
  end

  desc "Runs composer to install vendors from composer.lock file"
  task :install, :roles => :app, :except => { :no_release => true } do
    if !composer_bin
      composer.get
      set :composer_bin, "#{php_bin} composer.phar"
    end

    run "#{try_sudo} sh -c 'cd #{latest_release} && #{composer_bin} install #{composer_options}'"
  end

end