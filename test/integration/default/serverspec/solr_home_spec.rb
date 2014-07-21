require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  c.before :all do
    c.path = '/sbin:/usr/sbin'
  end
end

describe "Solr home-directory" do

  it "creates the directory /srv/solr" do
    expect(file('/srv/solr')).to be_directory
  end

end