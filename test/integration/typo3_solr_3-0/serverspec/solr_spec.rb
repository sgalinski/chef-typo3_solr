require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  c.before :all do
    c.path = '/sbin:/usr/sbin'
  end
end

describe "Solr available" do

  it "should list all available cores" do
    command('wget -qO- http://localhost:8080/c015/admin/cores?action=STATUS').stdout.should match(/live\-MetallbringtsAt\-1\-0\-de\_AT/)
  end

end

describe "TYPO3-specific libraries are downloaded" do

  it "downloads typo3 acces-plugin" do
    expect(file('/srv/solr/c015/typo3lib/solr-typo3-access-2.0.jar')).to be_file
  end

  it "downloads typo3 utils-plugin" do
    expect(file('/srv/solr/c015/typo3lib/solr-typo3-utils-1.1.jar')).to be_file
  end

  it "downloads lang-plugin" do
    expect(file('/srv/solr/c015/typo3lib/commons-lang3-3.1.jar')).to be_file
  end

end