action :add do

  uri = URI("https://forge.typo3.org/projects/extension-solr/repository/revisions/solr_#{new_resource.extension}.x/raw")

  request = Net::HTTP.new uri.host
  response= request.request_head uri.path

  if response.code.to_i == 200
    remote_branch = "solr_#{new_resource.extension}.x"
  else
    remote_branch = "master"
  end

  if Gem::Version.new(new_resource.solr) >= Gem::Version.new('4.0.0')
    resources_path = "Resources/Solr"
  else
    resources_path = "resources/solr"
  end

  service "tomcat" do
    service_name "tomcat6"
    supports :restart => true, :reload => true, :status => true
  end

  if Gem::Version.new(new_resource.solr) >= Gem::Version.new('4.0.0')

    remote_file "#{Chef::Config[:file_cache_path]}/apache-solr-#{new_resource.solr}.tar.gz" do
      source "http://www.us.apache.org/dist/lucene/solr/#{new_resource.solr}/solr-#{new_resource.solr}.tgz"
      action :create_if_missing
    end
  else
    remote_file "#{Chef::Config[:file_cache_path]}/apache-solr-#{new_resource.solr}.tar.gz" do
      source "http://archive.apache.org/dist/lucene/solr/#{new_resource.solr}/apache-solr-#{new_resource.solr}.tgz"
      action :create_if_missing
    end
  end

  execute "decompress-solr-archive" do
    cwd Chef::Config[:file_cache_path]
    command "tar -xzf apache-solr-#{new_resource.solr}.tar.gz"
    creates "#{Chef::Config[:file_cache_path]}/apache-solr-#{new_resource.solr}/dist/apache-solr-#{new_resource.solr}.war"
  end

  # copy solr war-file

  if Gem::Version.new(new_resource.solr) >= Gem::Version.new('4.0.0')
    execute "rename-solr-dir" do
      cwd Chef::Config[:file_cache_path]
      command "mv solr-#{new_resource.solr} apache-solr-#{new_resource.solr}"
      creates "#{Chef::Config[:file_cache_path]}/apache-solr-#{new_resource.solr}"
    end

    execute "copy-solr-app" do
      cwd Chef::Config[:file_cache_path]
      command "cp apache-solr-#{new_resource.solr}/dist/solr-#{new_resource.solr}.war #{node[:tomcat][:webapp_dir]}/#{new_resource.name}.war"
      creates "#{node[:tomcat][:webapp_dir]}/#{new_resource.name}.war"
    end
  else
    execute "copy-solr-app" do
      cwd Chef::Config[:file_cache_path]
      command "cp apache-solr-#{new_resource.solr}/dist/apache-solr-#{new_resource.solr}.war #{node[:tomcat][:webapp_dir]}/#{new_resource.name}.war"
      creates "#{node[:tomcat][:webapp_dir]}/#{new_resource.name}.war"
    end
  end

  execute "copy-solr-libs" do
    cwd Chef::Config[:file_cache_path]
    command "cp apache-solr-#{new_resource.solr}/example/lib/ext/*.jar #{node["tomcat"]["home"]}/lib/"
    only_if { Gem::Version.new(new_resource.solr) >= Gem::Version.new('4.0.0') }
  end

  execute "chmod" do
    command "chmod -R 777 #{node["tomcat"]["home"]}/lib/"
  end

  execute "copy-log4j-properties" do
    cwd Chef::Config[:file_cache_path]
    command "cp apache-solr-#{new_resource.solr}/example/resources/log4j.properties #{node["tomcat"]["home"]}/lib/log4j.properties"
    creates "#{node["tomcat"]["home"]}/lib/log4j.properties"
    only_if { Gem::Version.new(new_resource.solr) >= Gem::Version.new('4.0.0') }
  end

  directory "#{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name}/typo3cores/conf" do
    owner node[:tomcat][:user]
    group "root"
    mode 0775
    action :create
    recursive true
  end

  execute "copy-solr-files" do
    cwd Chef::Config[:file_cache_path]
    command "cp -r apache-solr-#{new_resource.solr}/example/solr/* #{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name}/"
    creates
  end

  new_resource.languages.each do | language |
    directory "#{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name}/typo3cores/conf/#{language}" do
      owner node[:tomcat][:user]
      group "root"
      mode 0775
      action :create
    end

    %w{ protwords.txt schema.xml synonyms.txt }.each do | file |
      remote_file "#{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name}/typo3cores/conf/#{language}/#{file}" do
        source "https://forge.typo3.org/projects/extension-solr/repository/revisions/#{remote_branch}/raw/#{resources_path}/typo3cores/conf/#{language}/#{file}"
        action :create_if_missing
        owner node[:tomcat][:user]
        mode 0644
      end
	end

	remote_file "#{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name}/typo3cores/conf/#{language}/_schema_analysis_stopwords_#{language}.json" do
	  source "https://forge.typo3.org/projects/extension-solr/repository/revisions/#{remote_branch}/raw/#{resources_path}/typo3cores/conf/#{language}/_schema_analysis_stopwords_#{language}.json"
	  action :create_if_missing
	  owner node[:tomcat][:user]
	  mode 0644
    end

    remote_file "#{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name}/typo3cores/conf/#{language}/german-common-nouns.txt" do
      source "https://forge.typo3.org/projects/extension-solr/repository/revisions/#{remote_branch}/raw/#{resources_path}/typo3cores/conf/#{language}/german-common-nouns.txt"
      action :create_if_missing
      owner node[:tomcat][:user]
      mode 0644
      only_if { language === 'german' }
    end
  end

  %w{ elevate.xml general_schema_fields.xml general_schema_types.xml solrconfig.xml }.each do | file |
    remote_file "#{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name}/typo3cores/conf/#{file}" do
      source "https://forge.typo3.org/projects/extension-solr/repository/revisions/#{remote_branch}/raw/#{resources_path}/typo3cores/conf/#{file}"
      action :create_if_missing
      owner node[:tomcat][:user]
      mode 0664
    end
  end

  remote_file "#{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name}/typo3cores/conf/currency.xml" do
    source "https://forge.typo3.org/projects/extension-solr/repository/revisions/#{remote_branch}/raw/#{resources_path}/typo3cores/conf/currency.xml"
    action :create_if_missing
    owner node[:tomcat][:user]
    mode 0644
    only_if { Gem::Version.new(new_resource.extension) >= Gem::Version.new('2.8.0') }
  end

  file "#{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name}/solr.xml" do
    action :delete
  end

  template "#{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name}/solr.xml" do
    source "solr.xml.erb"
    #variables(:cores => node[:typo3_solr][:cores][new_resource.extension])
    owner node[:tomcat][:user]
    mode 0644
    cookbook 'typo3_solr'
  end

  %w{ bin conf data }.each do | directory |
    directory "#{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name}/#{directory}" do
      action :delete
      recursive true
    end
  end

  file "#{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name}/README.txt" do
    action :delete
  end

  template "#{node[:tomcat][:context_dir]}/#{new_resource.name}.xml" do
    source "tomcat_solr.xml.erb"
    variables(:app => new_resource.name)
    owner node[:tomcat][:user]
    mode 0644
    cookbook 'typo3_solr'
  end

  directory "#{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name}/dist" do
    action :create
    mode 0775
  end

  execute "copy-dist" do
    command "cp -r #{Chef::Config[:file_cache_path]}/apache-solr-#{new_resource.solr}/dist #{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name}/"
  end

  execute "copy-contrib" do
    command "cp -r #{Chef::Config[:file_cache_path]}/apache-solr-#{new_resource.solr}/contrib #{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name}/"
  end

  directory "#{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name}/typo3lib" do
    action :create
    mode 0775
  end

  # old typo3 solr plugin

  remote_file "#{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name}/typo3lib/solr-typo3-plugin-#{new_resource.plugin}.jar" do
    source "http://www.typo3-solr.com/fileadmin/files/solr/solr-typo3-plugin-#{new_resource.plugin}.jar"
    mode 0644
    notifies :restart, resources(:service => "tomcat"), :immediately
    only_if { Gem::Version.new(new_resource.plugin) > Gem::Version.new('0.0.0') }
  end

  # new typo3-solr plugins

  remote_file "#{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name}/typo3lib/solr-typo3-access-#{new_resource.plugin_access}.jar" do
    source "http://www.typo3-solr.com/fileadmin/files/solr/Solr4x/solr-typo3-access-#{new_resource.plugin_access}.jar"
    mode 0644
    notifies :restart, resources(:service => "tomcat"), :immediately
    only_if { Gem::Version.new(new_resource.plugin_access) > Gem::Version.new('0.0.0') }
  end

  remote_file "#{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name}/typo3lib/solr-typo3-utils-#{new_resource.plugin_utils}.jar" do
    source "http://www.typo3-solr.com/fileadmin/files/solr/Solr4x/solr-typo3-utils-#{new_resource.plugin_utils}.jar"
    mode 0644
    notifies :restart, resources(:service => "tomcat"), :immediately
    only_if { Gem::Version.new(new_resource.plugin_utils) > Gem::Version.new('0.0.0') }
  end

  remote_file "#{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name}/typo3lib/commons-lang3-#{new_resource.plugin_lang}.jar" do
    source "http://www.typo3-solr.com/fileadmin/files/solr/Solr4x/commons-lang3-#{new_resource.plugin_lang}.jar"
    mode 0644
    notifies :restart, resources(:service => "tomcat"), :immediately
    only_if { Gem::Version.new(new_resource.plugin_lang) > Gem::Version.new('0.0.0') }
  end

  # reset directory access restrictions

  execute "chown" do
    command "chown -R #{node[:tomcat][:user]}:#{node[:tomcat][:group]} #{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name} && chmod -R o+rw #{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name}"
  end

  new_resource.updated_by_last_action(true)
end

action :remove do
  service "tomcat" do
    service_name "tomcat6"
    supports :restart => true, :reload => true, :status => true
  end

  directory "#{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name}" do
    action :delete
    recursive true
  end

  file "#{node[:tomcat][:context_dir]}/#{new_resource.name}.xml" do
    action :delete
  end

  file "#{node[:tomcat][:webapp_dir]}/#{new_resource.name}.war" do
    action :delete
  end

  directory "#{node[:tomcat][:webapp_dir]}/#{new_resource.name}" do
    action :delete
    recursive true
    notifies :restart, resources(:service => "tomcat")
  end
end