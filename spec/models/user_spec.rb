require 'spec_helper'

describe User do

  it { should validate_presence_of(:password) }
  it { should ensure_length_of(:password).is_at_least(6).is_at_most(32) }

  it { should validate_presence_of(:email) }

  describe 'with all attributes' do
    subject{ Fabricate(:user) }

    it { should validate_uniqueness_of(:email) }

    its(:name) { should match(/\w?+ \w?+/) }
  end

  describe 'with no first/last name' do
    subject{ Fabricate(:user, :first_name => nil, :last_name => nil) }
    its(:name) { should match(/^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})$/) }
  end
end