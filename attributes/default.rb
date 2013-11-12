=begin
default[:typo3_solr][:versions] = {
    :Client15_Metallbringts => {
        :solr => '3.6.2',
        :ext => '2.8',
        :plugin => '1.2.0',
        :languages => %w{ german english french italian generic hungarian }
    },
    :Client8_MacHoffmann => {
        :solr => '3.5.0',
        :ext => '2.2',
        :plugin => '1.2.0',
        :languages => %w{ german english french italian generic hungarian }
    }
}
=end
default[:typo3_solr][:solr][:solr_home] = "/srv/solr"