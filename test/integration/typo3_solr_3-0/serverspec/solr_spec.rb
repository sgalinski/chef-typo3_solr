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