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
    command('wget -qO- http://127.0.0.1:8080/c015').stdout.should match(/live\-MetallbringtsAt\-1\-0\-de\_AT/)
  end

  it "should have the typo3 plugin loaded" do
    command('wget -qO- http://127.0.0.1:8080/c015/live-MetallbringtsAt-1-0-de_AT/admin/registry.jsp').stdout.should match(/org\.typo3\.solr\.search\.AccessFilterQParserPlugin/)
  end

end