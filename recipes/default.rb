#
# Cookbook Name:: typo3_solr
# Recipe:: default
#
# Copyright 2012, Philipp Bergsmann, opendo GmbH
#
# All rights reserved - Do Not Redistribute
#

include_recipe "tomcat"

directory node[:typo3_solr][:solr][:solr_home] do
  owner node[:tomcat][:user]
  group "root"
  mode 0770
  action :create
end

#execute "chmod" do
#  command "chmod -R 777 #{node[:typo3_solr][:solr][:solr_home]}"
#end