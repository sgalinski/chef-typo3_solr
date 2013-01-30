
typo3_solr_app "MacHoffmann" do
  solr '3.5.0'
  extension '2.2'
  plugin '1.2.0'
  languages %w{ german english french italian generic hungarian }
end

typo3_solr_core "de-TestWeb-123-de_DE" do
  language 'german'
  app 'MacHoffmann'
  action :add
end

typo3_solr_core "de-TestWeb33-123-de_DE" do
  language 'german'
  app 'MacHoffmann'
  action :add
end

=begin
typo3_solr_app "MacHoffmann" do
  action :remove
end
=end