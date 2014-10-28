typo3_solr_app "c015" do
  solr '4.7.2'
  solr '4.8.1'
  extension '3.0'
  plugin_access '2.0'
  plugin_utils '1.1'
  plugin_lang '3.1'
  languages %w{ german english }
end

typo3_solr_core "live-MetallbringtsAt-1-0-de_AT" do
  language 'german'
  app 'c015'
  action :add
  notifies :restart, resources(:service => "tomcat")
end
