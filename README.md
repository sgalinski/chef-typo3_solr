Description
===========

Requirements
============

Platform:

* Debian, Ubuntu

The following Opscode cookbooks are dependencies:

* tomcat

Attributes
==========

* `node[:typo3_solr][:solr][:solr_home]` - Path to the directory in which the apps should be located

Usage
=====

The following LWRPs are included:

`typo3_solr_app` is used to create a new webapp with the given configuration

typo3_solr_app "MySolrAppName" do
  solr '3.5.0'
  extension '2.2'
  plugin '1.2.0'
  languages %w{ german english french italian generic hungarian }
end

`typo3_solr_core` is used to attach cores to a already created webapp

typo3_solr_core "de-TestWeb-123-de_DE" do
  language 'german'
  app 'MySolrAppName'
  action :add
end