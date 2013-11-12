action :add do
  service "tomcat" do
    service_name "tomcat6"
    supports :restart => true, :reload => true, :status => true
  end

  remote_file "#{Chef::Config[:file_cache_path]}/apache-solr-#{new_resource.solr}.tar.gz" do
    source "http://archive.apache.org/dist/lucene/solr/#{new_resource.solr}/apache-solr-#{new_resource.solr}.tgz"
    action :create_if_missing
  end

  execute "decompress-solr-archive" do
    cwd Chef::Config[:file_cache_path]
    command "tar -xzf apache-solr-#{new_resource.solr}.tar.gz"
    creates "#{Chef::Config[:file_cache_path]}/apache-solr-#{new_resource.solr}/dist/apache-solr-#{new_resource.solr}.war"
  end

  execute "copy-solr-app" do
    cwd Chef::Config[:file_cache_path]
    command "cp apache-solr-#{new_resource.solr}/dist/apache-solr-#{new_resource.solr}.war #{node[:tomcat][:webapp_dir]}/#{new_resource.name}.war"
    creates "#{node[:tomcat][:webapp_dir]}/#{new_resource.name}.war"
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

    %w{ protwords.txt schema.xml stopwords.txt synonyms.txt }.each do | file |
      remote_file "#{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name}/typo3cores/conf/#{language}/#{file}" do
        source "https://forge.typo3.org/projects/extension-solr/repository/revisions/solr_#{new_resource.extension}.x/raw/resources/solr/typo3cores/conf/#{language}/#{file}"
        action :create_if_missing
        owner node[:tomcat][:user]
        mode 0644
      end
    end

    remote_file "#{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name}/typo3cores/conf/#{language}/german-common-nouns.txt" do
      source "https://forge.typo3.org/projects/extension-solr/repository/revisions/solr_#{new_resource.extension}.x/raw/resources/solr/typo3cores/conf/#{language}/german-common-nouns.txt"
      action :create_if_missing
      owner node[:tomcat][:user]
      mode 0644
      only_if { language === 'german' }
    end
  end

  %w{ admin-extra.html elevate.xml general_schema_fields.xml general_schema_types.xml solrconfig.xml }.each do | file |
    remote_file "#{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name}/typo3cores/conf/#{file}" do
      source "https://forge.typo3.org/projects/extension-solr/repository/revisions/solr_#{new_resource.extension}.x/raw/resources/solr/typo3cores/conf/#{file}"
      action :create_if_missing
      owner node[:tomcat][:user]
      mode 0664
    end
  end

  remote_file "#{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name}/typo3cores/conf/currency.xml" do
    source "https://forge.typo3.org/projects/extension-solr/repository/revisions/solr_#{new_resource.extension}.x/raw/resources/solr/typo3cores/conf/currency.xml"
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

  %w{ apache-solr-analysis-extras apache-solr-cell apache-solr-clustering apache-solr-dataimporthandler apache-solr-dataimporthandler-extras apache-solr-uima }.each do | file |
    execute "copy-dist" do
      command "cp #{Chef::Config[:file_cache_path]}/apache-solr-#{new_resource.solr}/dist/#{file}-#{new_resource.solr}.jar #{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name}/dist/"
    end
  end

  execute "copy-contrib" do
    command "cp -r #{Chef::Config[:file_cache_path]}/apache-solr-#{new_resource.solr}/contrib #{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name}/"
  end

  directory "#{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name}/typo3lib" do
    action :create
    mode 0775
  end

  remote_file "#{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name}/typo3lib/solr-typo3-plugin-#{new_resource.plugin}.jar" do
    source "http://www.typo3-solr.com/fileadmin/files/solr/solr-typo3-plugin-#{new_resource.plugin}.jar"
    mode 0644
    notifies :restart, resources(:service => "tomcat"), :immediately
  end

  execute "chown" do
    command "chown -R #{node[:tomcat][:user]}:#{node[:tomcat][:group]} #{node[:typo3_solr][:solr][:solr_home]}/#{new_resource.name}"
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