#
# Cookbook Name:: typo3_solr
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "tomcat"

package 'unzip'
package 'wget'

node[:typo3_solr][:versions].each do | version |
  remote_file "#{Chef::Config[:file_cache_path]}/apache-solr-#{version[:solr]}.tar.gz" do
    source "http://archive.apache.org/dist/lucene/solr/#{version[:solr]}/apache-solr-#{version[:solr]}.tgz"
    action :create_if_missing
  end

  execute "decompress-solr-archive" do
    cwd Chef::Config[:file_cache_path]
    command "tar -xzf apache-solr-#{version[:solr]}.tar.gz"
    creates "#{Chef::Config[:file_cache_path]}/apache-solr-#{version[:solr]}/dist/apache-solr-#{version[:solr]}.war"
  end

  execute "copy-solr-app" do
    cwd Chef::Config[:file_cache_path]
    command "cp apache-solr-#{version[:solr]}/dist/apache-solr-#{version[:solr]}.war #{node[:typo3_solr][:tomcat][:webapp_path]}/"
    creates "#{node[:typo3_solr][:tomcat][:webapp_path]}/apache-solr-#{version[:solr]}.war"
  end

  directory "#{node[:typo3_solr][:solr][:solr_home]}/solr-#{version[:solr]}" do
    owner node["tomcat"]["user"]
    group "root"
    mode 0664
    action :create
  end

  directory "#{node[:typo3_solr][:solr][:solr_home]}/solr-#{version[:solr]}/typo3cores" do
    owner node["tomcat"]["user"]
    group "root"
    mode 0664
    action :create
  end

  directory "#{node[:typo3_solr][:solr][:solr_home]}/solr-#{version[:solr]}/typo3cores/conf" do
    owner node["tomcat"]["user"]
    group "root"
    mode 0664
    action :create
  end

  execute "copy-solr-files" do
    cwd Chef::Config[:file_cache_path]
    command "cp -r apache-solr-#{version[:solr]}/example/solr/* #{node[:typo3_solr][:solr][:solr_home]}/solr-#{version[:solr]}/"
    creates
  end

  version[:languages].each do | language |
    directory "#{node[:typo3_solr][:solr][:solr_home]}/solr-#{version[:solr]}/typo3cores/conf/#{language}" do
      owner node["tomcat"]["user"]
      group "root"
      mode 0644
      action :create
    end

    %w{ protwords.txt schema.xml stopwords.txt synonyms.txt }.each do | file |
      remote_file "#{node[:typo3_solr][:solr][:solr_home]}/solr-#{version[:solr]}/typo3cores/conf/#{language}/#{file}" do
        source "https://forge.typo3.org/projects/extension-solr/repository/revisions/solr_#{version[:ext]}.x/raw/resources/solr/typo3cores/conf/#{language}/#{file}"
        action :create_if_missing
        owner node["tomcat"]["user"]
        mode 0644
      end
    end

    if language === 'german' then
      remote_file "#{node[:typo3_solr][:solr][:solr_home]}/solr-#{version[:solr]}/typo3cores/conf/#{language}/german-common-nouns.txt" do
        source "https://forge.typo3.org/projects/extension-solr/repository/revisions/solr_#{version[:ext]}.x/raw/resources/solr/typo3cores/conf/#{language}/german-common-nouns.txt"
        action :create_if_missing
        owner node["tomcat"]["user"]
        mode 0644
      end
    end
  end

  %w{ admin-extra.html elevate.xml general_schema_fields.xml general_schema_types.xml solrconfig.xml }.each do | file |
    remote_file "#{node[:typo3_solr][:solr][:solr_home]}/solr-#{version[:solr]}/typo3cores/conf/#{file}" do
      source "https://forge.typo3.org/projects/extension-solr/repository/revisions/solr_#{version[:ext]}.x/raw/resources/solr/typo3cores/conf/#{file}"
      action :create_if_missing
      owner node["tomcat"]["user"]
      mode 0664
    end
  end

  if Gem::Version.new(version[:ext]) >= Gem::Version.new('2.8.0') then
    remote_file "#{node[:typo3_solr][:solr][:solr_home]}/solr-#{version[:solr]}/typo3cores/conf/currency.xml" do
      source "https://forge.typo3.org/projects/extension-solr/repository/revisions/solr_#{version[:ext]}.x/raw/resources/solr/typo3cores/conf/currency.xml"
      action :create_if_missing
      owner node["tomcat"]["user"]
      mode 0644
    end
  end

  file "#{node[:typo3_solr][:solr][:solr_home]}/solr-#{version[:solr]}/solr.xml" do
    action :delete
  end

  remote_file "#{node[:typo3_solr][:solr][:solr_home]}/solr-#{version[:solr]}/solr.xml" do
    source "https://forge.typo3.org/projects/extension-solr/repository/revisions/solr_#{version[:ext]}.x/raw/resources/solr/solr.xml"
    action :create_if_missing
    owner node["tomcat"]["user"]
    mode 0644
  end

  %w{ bin conf data }.each do | directory |
    directory "#{node[:typo3_solr][:solr][:solr_home]}/solr-#{version[:solr]}/#{directory}" do
      action :delete
      recursive true
    end
  end

  file "#{node[:typo3_solr][:solr][:solr_home]}/solr-#{version[:solr]}/README.txt" do
    action :delete
  end

  template "#{node[:typo3_solr][:tomcat][:catalina_conf]}/apache-solr-#{version[:solr]}.xml" do
    source "tomcat_solr.xml.erb"
    variables(:version => version[:solr])
    owner node["tomcat"]["user"]
    mode 0644
  end

  directory "#{node[:typo3_solr][:solr][:solr_home]}/solr-#{version[:solr]}/dist" do
    action :create
    mode 0644
  end

  %w{ apache-solr-analysis-extras apache-solr-cell apache-solr-clustering apache-solr-dataimporthandler apache-solr-dataimporthandler-extras apache-solr-uima }.each do | file |
    execute "copy-dist" do
      command "cp #{Chef::Config[:file_cache_path]}/apache-solr-#{version[:solr]}/dist/#{file}-#{version[:solr]}.jar #{node[:typo3_solr][:solr][:solr_home]}/solr-#{version[:solr]}/dist/"
    end
  end

  execute "copy-contrib" do
    command "cp -r #{Chef::Config[:file_cache_path]}/apache-solr-#{version[:solr]}/contrib #{node[:typo3_solr][:solr][:solr_home]}/solr-#{version[:solr]}/"
  end

  directory "#{node[:typo3_solr][:solr][:solr_home]}/solr-#{version[:solr]}/typo3lib" do
    action :create
    mode 0644
  end

  remote_file "#{node[:typo3_solr][:solr][:solr_home]}/solr-#{version[:solr]}/typo3lib/solr-typo3-plugin-#{version[:plugin]}.jar" do
    source "http://www.typo3-solr.com/fileadmin/files/solr/solr-typo3-plugin-#{version[:plugin]}.jar"
    mode 0644
  end

  execute "chown" do
    command "chown -R #{node["tomcat"]["user"]}:#{node["tomcat"]["group"]} #{node[:typo3_solr][:solr][:solr_home]}/solr-#{version[:solr]} && chmod -R a+x #{node[:typo3_solr][:solr][:solr_home]}/solr-#{version[:solr]}"
  end
end

=begin

cookbook_file "/usr/local/bin/install-solr-debian6-without-tomcat.sh" do
  source "install-solr-debian6-without-tomcat.sh"
  mode 0755
  owner "root"
  group "root"
end

execute "install-solr-debian6-without-tomcat" do
  command "/usr/local/bin/install-solr-debian6-without-tomcat.sh #{node[:typo3_solr][:languages]}"
  creates "/opt/solr-tomcat/solr/solr.xml"
  action :run
end

template "/etc/tomcat6/server.xml" do
  source "server.xml.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "tomcat")
end

template "/opt/solr-tomcat/solr/solr.xml" do
  source "solr.xml.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "tomcat")
end
=end
