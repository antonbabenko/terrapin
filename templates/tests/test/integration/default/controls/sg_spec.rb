require 'awspec'
Awsecrets.load

sg_name = attribute 'sg_name', {}

control 'default' do
  describe "the sg #{sg_name}" do
    subject { security_group(sg_name) }

    it { should exist }
  end
end
