# frozen_string_literal: true

require 'rails_helper'

describe 'EZID XML' do
  before(:each) do
    @dmp = create(:data_management_plan, :complete, contributors_count: 2)
    # Ensure all of the fundings have been granted and they have a Fundref!
    @dmp.project.fundings.each do |funding|
      funding.affiliation.identifiers << build(:identifier, category: 'fundref', descriptor: 'is_identified_by',
                                                            provenance: @dmp.provenance,
                                                            value: 'https://api.crossref.org/funders/100000001')
      funding.status = 'granted'
    end
    @dmp.identifiers << build(:identifier, category: 'url', descriptor: 'is_cited_by', provenance: @dmp.provenance)
    @presenter = DatacitePresenter.new(@dmp)
    render template: 'ezid/minter', locals: { data_management_plan: @dmp }

    lines = rendered.split(/[\r\n]/)
    @target = lines.select { |l| l.split(':').first == '_target' }.first.gsub('_target: ', '')
    xml = rendered.gsub(/[\r\n]_target: #{@target}[\r\n]datacite: /, '')
    @xml = Nokogiri::XML(xml)
  end

  it 'has a _target attribute that contains the URL to the DMP landing page' do
    expect(@target).to eql(@presenter.landing_page)
  end
  it 'has a datacite attribute that contains XML' do
    expect(@xml.present?)
  end

  context 'datacite XML' do
    it 'has resource as the root element' do
      subject = @xml.xpath('//resource')
      expect(subject.first.present?)
    end
    it 'has an <identifer> element' do
      subject = @xml.css('identifier')
      expect(subject.present?)
      expect(subject.attr('identifierType').value).to eql('DOI')
      expect(subject.children.first.text.strip).to eql('(:tba)')
    end
    it 'has a <creators><creator> element' do
      expect(@xml.css('creators creator').length.positive?).to eql(true)
      subject = @xml.css('creators creator').first
      expect(subject.present?)
    end

    context '<creator>' do
      it 'has a <creatorName> element' do
        subject = @xml.css('creators creator').first.css('creatorName')
        expect(subject.attr('nameType').value).to eql('Personal')
        expect(subject.children.first.text.strip).to eql(@presenter.creators.first.name_last_first)
      end
      it 'has a <nameIdentifier> element if the creator has an ORCID' do
        subject = @xml.css('creators creator').first.css('nameIdentifier')
        expect(subject.attr('nameIdentifierScheme').value).to eql('ORCID')
        expect(subject.children.first.text.strip).to eql(@presenter.creators.first.orcids.last.value)
      end
      it 'has an <affiliation> element if the creator has an affiliation' do
        subject = @xml.css('creators creator').first.css('affiliation')
        expect(subject.attr('affiliationIdentifierScheme').value).to eql('ROR')
        expected = @presenter.creators.first.affiliation
        expect(subject.attr('affiliationIdentifier').value).to eql(expected.rors.first.value)
        expect(subject.children.first.text.strip).to eql(expected.name)
      end
    end

    it 'has a <titles><title> element' do
      expect(@xml.css('titles title').length).to eql(1)
      subject = @xml.css('titles title').first
      expect(subject.present?)
      expect(subject.attr('xml:lang')).to eql('en-US')
      expect(subject.children.first.text).to eql(@dmp.title)
    end
    it 'has an <publisher> element' do
      subject = @xml.css('publisher')
      expect(subject.present?)
      expect(subject.children.first.text.strip).to eql('DMPHub')
    end
    it 'has an <publicationYear> element' do
      subject = @xml.css('publicationYear')
      expect(subject.present?)
      expect(subject.children.first.text.strip).to eql(Time.now.year.to_s)
    end
    it 'has a <contributors><contributor> element' do
      expect(@xml.css('contributors contributor').length.positive?).to eql(true)
      subject = @xml.css('contributors contributor').first
      expect(subject.present?)
    end

    context '<contributor[contributorType="HostingInstituton"]>' do
      before(:each) do
        @contributor = @xml.css('contributors contributor[contributorType="HostingInstitution"]').first
      end
      it 'has a <contributorName> element' do
        subject = @contributor.css('contributorName')
        expect(subject.attr('nameType').value).to eql('Organizational')
        expect(subject.children.first.text.strip).to eql(@presenter.hosting_institution[:name])
      end
      it 'has a <nameIdentifier> element if the creator has a ROR' do
        subject = @contributor.css('nameIdentifier')
        expect(subject.attr('nameIdentifierScheme').value).to eql(@presenter.hosting_institution[:scheme])
        expect(subject.children.first.text.strip).to eql(@presenter.hosting_institution[:identifier])
      end
    end
    context '<contributor[contributorType="Producer"]>' do
      before(:each) do
        @contributor = @xml.css('contributors contributor[contributorType="Producer"]').first
      end
      it 'has a <contributorName> element' do
        subject = @contributor.css('contributorName')
        expect(subject.attr('nameType').value).to eql('Organizational')
        expect(subject.children.first.text.strip).to eql(@presenter.producers.first.name)
      end
      it 'has a <nameIdentifier> element if the creator has a ROR' do
        subject = @contributor.css('nameIdentifier')
        expect(subject.attr('nameIdentifierScheme').value).to eql('ROR')
        expect(subject.children.first.text.strip).to eql(@presenter.producers.first.rors.last.value)
      end
    end
    context '<contributor[contributorType="Personal"]>' do
      before(:each) do
        contributors = @xml.css('contributors contributor')
        @contributor = contributors.reject { |c| %w[HostingInstitution Producer].include?(c.attr('contributorType')) }.first

        p 'INTERMITTENT FAILURE:' if @contributor.nil?
        p @presenter.creators.inspect if @contributor.nil?
        p @presenter.contributors.inspect if @contributor.nil?
      end
      it 'has a <contributorName> element' do
        subject = @contributor.css('contributorName')
        expect(subject.attr('nameType').value).to eql('Personal')
        expect(subject.children.first.text.strip).to eql(@presenter.contributors.first.contributor.name_last_first)
      end
      it 'has a <nameIdentifier> element if the creator has an ORCID' do
        subject = @contributor.css('nameIdentifier')
        expect(subject.attr('nameIdentifierScheme').value).to eql('ORCID')
        expect(subject.children.first.text.strip).to eql(@presenter.contributors.first.contributor.orcids.last.value)
      end
      it 'has an <affiliation> element if the creator has an affiliation' do
        subject = @contributor.css('affiliation')
        expect(subject.attr('affiliationIdentifierScheme').value).to eql('ROR')
        expected = @presenter.contributors.first.contributor.affiliation
        expect(subject.attr('affiliationIdentifier').value).to eql(expected.rors.first.value)
        expect(subject.children.first.text.strip).to eql(expected.name)
      end
    end

    it 'has an <language> element' do
      subject = @xml.css('language')
      expect(subject.present?)
      expect(subject.children.first.text.strip).to eql('en-US')
    end
    it 'has an <resourceType> element' do
      subject = @xml.css('resourceType')
      expect(subject.present?)
      expect(subject.attr('resourceTypeGeneral').value).to eql('Text')
      expect(subject.children.first.text.strip).to eql('Data Management Plan')
    end
    it 'has a <descriptions><description> element' do
      expect(@xml.css('descriptions description').length).to eql(1)
      subject = @xml.css('descriptions description').first
      expect(subject.present?)
      expect(subject.attr('xml:lang')).to eql('en-US')
      expect(subject.attr('descriptionType')).to eql('Abstract')
      expect(subject.children.first.text.strip).to eql(@dmp.description)
    end
    it 'has a <fundingReferences><fundingReference> element' do
      expect(@xml.css('fundingReferences fundingReference').length.positive?).to eql(true)
      subject = @xml.css('fundingReferences fundingReference').first
      expect(subject.present?)
    end

    context '<fundingReference>' do
      before(:each) do
        @expected = @dmp.project.fundings.first
      end
      it 'has a <funderName> element' do
        subject = @xml.css('fundingReferences fundingReference').first.css('funderName')
        expect(subject.children.first.text.strip).to eql(@expected.affiliation.name)
      end
      it 'has a <funderIdentifier> element' do
        subject = @xml.css('fundingReferences fundingReference').first.css('funderIdentifier')
        expect(subject.attr('funderIdentifierType').value).to eql('Crossref Funder')
        expect(subject.children.first.text.strip).to eql(@expected.affiliation.fundrefs.last.value)
      end
      it 'has an <awardNumber> element' do
        subject = @xml.css('fundingReferences fundingReference').first.css('awardNumber')
        expect(subject.attr('awardURI').value).to eql(@expected.urls.last.value)
        expect(subject.children.first.text.strip).to eql(@presenter.award_number(funding: @expected))
      end
      it 'has a <awardTitle> element' do
        subject = @xml.css('fundingReferences fundingReference').first.css('awardTitle')
        expect(subject.children.first.text.strip).to eql(@dmp.title)
      end
    end

    it 'has a <relatedIdentifiers><relatedIdentifier> element' do
      expect(@xml.css('relatedIdentifiers relatedIdentifier').length.positive?).to eql(true)
      subject = @xml.css('relatedIdentifiers relatedIdentifier').first
      expect(subject.present?)
    end

    context '<relatedIdentifiers>' do
      before(:each) do
        @expected = @presenter.related_identifiers.first
      end
      it 'has a relationType attribute' do
        subject = @xml.css('relatedIdentifiers relatedIdentifier').first
        expect(subject.attr('relationType')).to eql(@presenter.relation_type(identifier: @expected))
      end
      it 'has a relatedIdentifierType attribute' do
        subject = @xml.css('relatedIdentifiers relatedIdentifier').first
        expect(subject.attr('relatedIdentifierType')).to eql(@presenter.related_identifier_type(identifier: @expected))
      end
      it 'has the identifier value' do
        subject = @xml.css('relatedIdentifiers relatedIdentifier').first
        expect(subject.children.first.text.strip).to eql(@expected.value)
      end
    end
  end
end
