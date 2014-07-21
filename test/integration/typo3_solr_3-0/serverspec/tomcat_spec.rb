require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  c.before :all do
    c.path = '/sbin:/usr/sbin'
  end
end

describe "Tomcat available" do

  it "should be listening on port 8080" do
    expect(port(8080)).to be_listening.with('tcp6')
  end

end