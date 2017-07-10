terraform_state = attribute 'terraform_state', {}

control 'state_file' do
  describe 'the Terraform state file' do
    subject { json(terraform_state).terraform_version }

    it('is accessible') { is_expected.to match(/\d+\.\d+\.\d+/) }
  end
end
