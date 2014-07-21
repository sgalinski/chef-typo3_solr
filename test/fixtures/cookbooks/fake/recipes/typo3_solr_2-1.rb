typo3_solr_app "c015" do
  solr '3.5.0'
  extension '2.1'
  plugin '1.2.0'
  languages %w{ german english }
end

typo3_solr_core "live-MetallbringtsAt-1-0-de_AT" do
  language 'german'
  app 'c015'
  action :add
  notifies :restart, resources(:service => "tomcat")
end