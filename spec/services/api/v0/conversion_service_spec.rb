# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V0::ConversionService do
  describe 'boolean_to_yes_no_unknown' do
    it 'returns `yes` when true' do
      expect(described_class.boolean_to_yes_no_unknown(true)).to eql('yes')
    end
    it 'returns `yes` when 1' do
      expect(described_class.boolean_to_yes_no_unknown(1)).to eql('yes')
    end
    it 'returns `no` when false' do
      expect(described_class.boolean_to_yes_no_unknown(false)).to eql('no')
    end
    it 'returns `no` when 0' do
      expect(described_class.boolean_to_yes_no_unknown(0)).to eql('no')
    end
    it 'returns `unknown` when nil' do
      expect(described_class.boolean_to_yes_no_unknown(nil)).to eql('unknown')
    end
  end

  describe 'yes_no_unknown_to_boolean' do
    it 'returns true when `yes`' do
      expect(described_class.yes_no_unknown_to_boolean('yes')).to eql(true)
    end
    it 'returns false when `no`' do
      expect(described_class.yes_no_unknown_to_boolean('no')).to eql(false)
    end
    it 'returns nil when `unknown`' do
      expect(described_class.yes_no_unknown_to_boolean('unknown')).to eql(nil)
    end
  end
end
