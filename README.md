Description
===========

**This is alpha software! It is used in production, but it is not guaranteed to work with your setup!***

This chef cookbook is based on the shell-scripts which are distributed with the EXT:solr (thank you Ingo Renner!). The
cookbook offers two LWRPs which should be enough to setup a solr app with unlimited solr cores.

Requirements
============

Platform:

* Debian, Ubuntu

The following Opscode cookbooks are dependencies:

* tomcat

If you want to user this cookbook with EXT:solr >= 3.0 you have to install java 7 on your system. When using the
java-cookbook, you need to override this attribute:

```ruby
node[:java][:jdk_version] = "7"
```

Attributes
==========

* `node[:typo3_solr][:solr][:solr_home]` - Path to the directory in which the apps should be located

Usage
=====

The following LWRPs are included:

`typo3_solr_app` is used to create a new webapp with the given configuration

*For instances requiring Apache Solr < 4*

```ruby
typo3_solr_app "MySolrAppName" do
  solr '3.5.0'
  extension '2.2'
  plugin '1.2.0'
  languages %w{ german english french italian generic hungarian }
end
```

*For instances requiring Apache Solr > 4*

```ruby
typo3_solr_app "MySolrAppName" do
  solr '4.7.1'
  extension '3.0'
  plugin_access '2.0'
  plugin_utils '1.1'
  plugin_lang '3.1'
  languages %w{ german english french italian generic hungarian }
end
```

`typo3_solr_core` is used to attach cores to a already created webapp

```ruby
typo3_solr_core "de-TestWeb-123-de_DE" do
  language 'german'
  app 'MySolrAppName'
  action :add
end
```

License and Author
==================

Author: Philipp Bergsmann (<p.bergsmann@opendo.at>)

Copyright: 2014 opendo GmbH (http://opendo.at)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
