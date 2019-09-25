# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_presence_of(:password) }
    it { is_expected.to validate_acceptance_of(:accept_terms) }

    it 'should validate that email address is unique' do
      subject.email = 'text-email@example.com'
      is_expected.to validate_uniqueness_of(:email)
        .case_insensitive
        .with_message('has already been taken')
    end
  end

  context 'associations' do
    it { is_expected.to have_many(:access_grants) }
    it { is_expected.to have_many(:access_tokens) }
    it { is_expected.to belong_to(:organization) }
  end

  it 'factory can produce a valid model' do
    model = create(:user, organization: create(:organization))
    expect(model.valid?).to eql(true)
  end

  context 'instance methods' do
    describe '#first_name=' do
      it 'is capitalized' do
        usr = build(:user, last_name: 'foo')
        expect(usr.last_name).to eql('Foo')
      end
    end

    describe '#last_name=' do
      it 'is capitalized' do
        usr = build(:user, last_name: 'foo')
        expect(usr.last_name).to eql('Foo')
      end
    end

    describe '#name' do
      before(:each) do
        @user = build(:user)
      end

      it "returns the user's full name" do
        expect(@user.name).to eq("#{@user.first_name} #{@user.last_name}")
      end
      it "returns the user's first name if there is no last name" do
        @user.last_name = nil
        expect(@user.name).to eq(@user.first_name.to_s)
      end
      it "returns the user's last name if there is no first name" do
        @user.first_name = nil
        expect(@user.name).to eq(@user.last_name.to_s)
      end
      it "returns the user's email if no names are available" do
        @user.first_name = nil
        @user.last_name = nil
        expect(@user.name).to eq(@user.email.to_s)
      end
    end
  end
end
