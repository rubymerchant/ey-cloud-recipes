appname = "theauteurscom2"

if %w(solo app app_master).include?(node[:instance_role])
  user = node[:owner_name]
  framework_env = node[:environment][:framework_env]

  run_for_app appname do |app_name, data|
    worker_name = "dj_#{app_name}"

    directory "/data/#{app_name}/shared/pids" do
      owner user
      group user
      mode 0755
    end

    template "/etc/monit.d/dj.#{app_name}.monitrc" do
      source 'dj.monitrc.erb'
      owner 'root'
      group 'root'
      mode 0644
      variables(
        :app_name => app_name,
        :user => user,
        :worker_name => worker_name,
        :framework_env => framework_env
      )
    end

    bash 'monit-reload-restart' do
      user 'root'
      code 'monit reload && monit'
    end
  end
end