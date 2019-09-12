# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ConversionService, type: :model do

  describe 'boolean_to_yes_no_unknown' do

    it 'returns `yes` when true' do
      expect(ConversionService.boolean_to_yes_no_unknown(true)).to eql('yes')
    end
    it 'returns `no` when false' do
      expect(ConversionService.boolean_to_yes_no_unknown(false)).to eql('no')
    end
    it 'returns `unknown` when nil' do
      expect(ConversionService.boolean_to_yes_no_unknown(nil)).to eql('unknown')
    end

  end

  describe 'yes_no_unknown_to_boolean' do

    it 'returns true when `yes`' do
      expect(ConversionService.yes_no_unknown_to_boolean('yes')).to eql(true)
    end
    it 'returns false when `no`' do
      expect(ConversionService.yes_no_unknown_to_boolean('no')).to eql(false)
    end
    it 'returns nil when `unknown`' do
      expect(ConversionService.yes_no_unknown_to_boolean('unknown')).to eql(nil)
    end

  end

end
