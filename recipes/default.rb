Chef::Log.level = :debug

app = search(:aws_opsworks_app).first
app_path = "/srv/#{app['shortname']}"
test = "once again"

package "git" do
  # workaround for:
  # WARNING: The following packages cannot be authenticated!
  # liberror-perl
  # STDERR: E: There are problems and -y was used without --force-yes
  options "--force-yes" if node["platform"] == "ubuntu" && node["platform_version"] == "14.04"
end

application app_path do
  javascript "4"
  environment.update("PORT" => "80")
  environment.update(app["environment"])

  git app_path do
    log 'node:'
    log node
    deploy_key node["deploy"][app['shortname']]["scm"]["ssh_key"]
    repository app["app_source"]["url"]
    revision app["app_source"]["revision"]
  end

  link "#{app_path}/server.js" do
    to "#{app_path}/index.js"
  end

  npm_install
  npm_start do
    action [:stop, :enable, :start]
  end
end
