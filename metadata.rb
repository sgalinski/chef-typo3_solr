name             "typo3_solr"
maintainer       "Philipp Bergsmann, opendo GmbH"
maintainer_email "p.bergsmann@opendo.at"
license          "All rights reserved"
description      "Installs/Configures TYPO3 EXT:solr"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version "1.2.0"

%w{ tomcat }.each do |cb|
  depends cb
end
