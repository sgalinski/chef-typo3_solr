default[:typo3_solr][:languages] = "german english french italian generic hungarian"
default[:typo3_solr][:packages] = { :wget => '', :unzip => '' }
default[:typo3_solr][:versions] = [
    {
        :solr => '3.6.2',
        :ext => '2.8',
        :plugin => '1.2.0',
        :languages => %w{ german english french italian generic hungarian }
    },
    {
        :solr => '3.5.0',
        :ext => '2.2',
        :plugin => '1.2.0',
        :languages => %w{ german english french italian generic hungarian }
    }
]
default[:typo3_solr][:tomcat][:webapp_path] = "/var/lib/tomcat6/webapps"
default[:typo3_solr][:tomcat][:catalina_conf] = "/etc/tomcat6/Catalina/localhost"
default[:typo3_solr][:solr][:solr_home] = "/opt/solr-tomcat"