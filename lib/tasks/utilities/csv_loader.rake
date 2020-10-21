# frozen_string_literal: true

require 'httparty'

namespace :csv_loader do

  desc 'Converts the CSV files to JSON and imports them into the DMPHub'
  task process: :environment do
    Dir.entries("#{Rails.root}/tmp/import/").each do |file|
      File.delete("#{Rails.root}/tmp/import/#{file}") if file.end_with?('.json')
    end

    Rake::Task['csv_loader:csv_to_json'].execute
    Rake::Task['csv_loader:import'].execute
  end

  # This task picks up any JSON files in `tmp/import` and sends them through to
  # the API.
  desc 'Imports (via the CreationService) all JSON files in tmp/import'
  task import: :environment do
    base = "#{Rails.root}/tmp/import/"
    p 'No tmp/import folder found!' unless Dir.exist?(base)

    Dir.entries(base).each do |file|
      next unless file.end_with?('.json')

      client = ApiClient.where(name: 'dmphub').first
      provenance = Provenance.where(name: 'dmphub').first
      json = JSON.parse(File.read("#{base}#{file}"))

      counter = 0
      p "File, #{file}, contains #{json.length} DMPs. Processing records ..."

      json.each do |hash|
        hash = hash.with_indifferent_access
        next unless hash[:dmp].present?

        dmp = Api::V0::Deserialization::DataManagementPlan.deserialize(
          provenance: provenance, json: hash[:dmp]
        )

        dmp = PersistenceService.process_full_data_management_plan(
          client: client,
          dmp: dmp,
          history_description: 'Rake - CsvLoader Ingest',
          mintable: true
        )
        counter += 1
        p "  processed #{dmp.doi.value} - #{dmp.title}"
      rescue StandardError => e
        p "Some errors were encountered while processing: '#{hash[:dmp][:title]}'"
        p e.message
        next
      end

      p "Complete - #{counter} DMPs loaded to the system. Make sure you delete the file!"
    rescue JSON::ParserError
      p "JSON Parse error: Unable to parse the contents of #{file}. Skipping to next file."
    end
  end

  # This task will examine any CSV files in the tmp/csv directory and construct
  # DMP JSON that is ready for ingest into the API.
  #
  # It expects ALL of the files to use the `project` column to uniquely identify
  # and connect records between files (for example if one file contains the basic
  # information about the DMP like title, abstract and funding and a second file
  # contains the list of contributors on separate lines). For example:
  #     File 1:
  #         project  |  title    |  award_url
  #         ---------------------------------
  #         12345    | "Foo bar" | http://award.org/123
  #
  #    File 2:
  #         project  |  contributor_name  |  orcid               |  role
  #         ---------------------------------------------------------------------
  #         12345    |  "Doe, Jane"       | "000-0000-0000-000x" | "Investigator"
  #
  # This means that `project` is the only required field for each file. Once all
  # of the files have been processed though, a DMP MUST contain the following or
  # it will not be written to the final JSON output:
  #   `dmp_url`            -> The URL to the DMP PDF or publicly accessible copy
  #   `title`              -> This can be either the title of the DMP or the project
  #   `contributor_name`   -> At least one contributor MUST be specified
  #   `affiliation`        -> The contributor's affiliation name (the system will acquire the ROR id)
  #   `role`               -> The contributor's role (from https://dictionary.casrai.org/Contributor_Roles/
  #                                                     or http://ocean-data.org/schema/)
  #
  # The other optional fields are:
  #   `award_number`       -> For NSF awards only ... The NSF url will be appended
  #   `award_url`          -> The URL to the award landing page/metadata
  #   `funder_name`        -> The name of the funding agency (the system will acquire ROR and FundRef ids)
  #   `project_start`      -> The project's start date
  #   `project_end`        -> The project's end date
  #   `abstract`           -> The DMP or project's abstract
  #   `dataset_doi`        -> The DOI of the dataset
  #   `dataset_url`        -> The URL of the dataset if it does not have a DOI
  #   `related_doi`        -> The DOI of a related publication
  #   `ethical_issues`     -> Whether or not the DMP has ethical issues - expects 'yes|no' (defaults to 'unknown')
  #
  desc 'Converts any CSV files in tmp/csv into RDA common standard JSON and places them in tmp/import'
  task csv_to_json: :environment do
    base = "#{Rails.root}/tmp/csv/"
    p 'No tmp/csv folder found!' unless Dir.exist?(base)

    projects = []
    dmps = {}

    Dir.entries(base).each do |file|
      next unless file.end_with?('.csv')

      # Open the file
      csv = CSV.read("#{base}#{file}", headers: true, force_quotes: true, encoding: 'iso-8859-1:utf-8')
      p "Skipping #{file} which does not contain the require `project` column" unless csv.first['project'].present?
      next unless csv.first['project'].present?

      p "Importing #{file} ***"

      # Collect all of the unique projects
      projects << csv.map { |line| line['project'] }.uniq
      projects = projects.flatten.uniq

      csv.each do |line|
        # Debug line that's useful for isolating a single project
        # next unless line['project'] == 'http://lod.bco-dmo.org/id/project/560580'

        # Retrieve the existing DMP hash or initialize one
        hash = dmps[:"#{line['project']}"] || {}
        dmp_hash = hash.fetch(:dmp, { ethical_issues_exist: 'unknown' })
        dmp_hash[:dmp_id] = { type: 'URL', identifier: line['dmp_url'] } unless dmp_hash[:dmp_id].present? || !line['dmp_url'].present?
        dmp_hash[:ethical_issues_exist] = line['ethical_issues'] if line['ethical_issues'].present? && dmp_hash[:ethical_issues_exist] == 'unknown'

        dmp_hash = process_column(hash: dmp_hash, line: line, column: 'title', attr: :title)
        dmp_hash = process_column(hash: dmp_hash, line: line, column: 'abstract', attr: :description)

        dmp_hash = attach_project(hash: dmp_hash, line: line)
        dmp_hash = attach_contributor(hash: dmp_hash, line: line)
        # Commenting out because we're really loading actual Datasets not the DMP 'idea' of a dataset
        # dmp_hash = attach_dataset(hash: dmp_hash, line: line)

        # Attach any related identifiers
        dmp_hash = attach_related_identifier(hash: dmp_hash, value: line['project'])
        dmp_hash = attach_related_identifier(hash: dmp_hash, value: line['dataset_doi'], type: 'DOI')
        dmp_hash = attach_related_identifier(hash: dmp_hash, value: line['dataset_url'])
        dmp_hash = attach_related_identifier(hash: dmp_hash, value: line['related_doi'], type: 'DOI')

        # Add/Overwrite the previous DMP hash
        dmps[:"#{line['project']}"] = { dmp: dmp_hash }
      end
    end

    if dmps.any?
      p "Processed #{dmps.length} DMPs. Extracting viable DMPs for import into DMPHub ..."

      # Debug line to isolate a specific Project
      # output = []
      # dmps.each_pair do |_project, dmp|
        # # Only grabbing 14 titles
        # titles = [
          # 'Gene content, gene expression, and physiology in mesopelagic ammonia-oxidizing archaea',
          # 'The ProteOMZ Expedition: Investigating Life Without Oxygen in the Pacific Ocean',
          # 'Collaborative Research: New Approaches to New Production',
          # 'Collaborative research: Quantifying the biological, chemical, and physical linkages between chemosynthetic communities and the surrounding deep sea',
          # 'Convergence: RAISE: Linking the adaptive dynamics of plankton with emergent global ocean biogeochemistry',
          # 'Adaptations of fish and fishing communities to rapid climate change',
          # 'Collaborative Research: Use of Triple Oxygen Isotopes and O2/Ar to constrain Net/Gross Oxygen Production during upwelling and non-upwelling periods in a Coastal Setting',
          # 'Quantifying the potential for biogeochemical feedbacks to create \'refugia\' from ocean acidification on tropical coral reefs',
          # 'Collaborative Research: Dissolved organic matter feedbacks in coral reef resilience: The genomic & geochemical basis for microbial modulation of algal phase shifts',
          # 'Collaborative Research: Diatoms, Food Webs and Carbon Export - Leveraging NASA EXPORTS to Test the Role of Diatom Physiology in the Biological Carbon Pump',
          # 'Turbulence-spurred settlement: Deciphering a newly recognized class of larval response',
          # 'Collaborative Research: Field test of larval behavior on transport and connectivity in an upwelling regime',
          # 'Impacts of size-selective mortality on sex-changing fishes',
          # 'Collaborative Research: Ocean Acidification and Coral Reefs: Scale Dependence and Adaptive Capacity'
        # ]
        # next unless titles.include?(dmp[:dmp][:title])

        # output << dmp
      # end

      output = dmps.values

      # Extract the Contact
      dmps = handle_contacts(dmps: output)

      # Only output the ones where we have a Contact with an Affiliation
      dmps = dmps.select { |dmp| dmp[:dmp].fetch(:contact, {}).fetch(:affiliation, {})[:name].present? }

      p "... writing #{dmps.length} DMPs for import into the Hub"

      now = Time.now
      file_name = "#{Rails.root}/tmp/import/#{now.year}_#{now.month}_#{now.day}_bco_dmo.json"
      file = File.open(file_name, 'w')
      file.write(dmps.to_json)
      file.close
      p "Complete - output file written to: #{file_name}"
    else
      p 'No DMPs could be derived from the data in the CSV files provided.'
    end
  end

  private

  # Attaches the column value to the hash attribute if it does not already exist
  def process_column(hash:, line:, column:, attr:)
    return hash unless hash.is_a?(Hash) && line.present? && line[column].present? && !hash[attr].present?

    hash[attr] = line[column]
    hash
  end

  # Attach the project metadata
  def attach_project(hash:, line:)
    return hash unless hash.present? && line.present? && (line['project_start'].present? || line['project_end'].present?)

    projects = hash.fetch(:project, [])
    if projects.any?
      project_hash = projects.first
    else
      project_hash = {}
      project_hash = process_column(hash: project_hash, line: line, column: 'title', attr: :title)
      project_hash = process_column(hash: project_hash, line: line, column: 'project_start', attr: :start)
      project_hash = process_column(hash: project_hash, line: line, column: 'project_end', attr: :end)

      # Cleanse any Dates
      project_hash[:start] = process_date(date: project_hash[:start]) if project_hash[:start].present?
      project_hash[:end] = process_date(date: project_hash[:end]) if project_hash[:end].present?
    end
    project_hash = attach_funding(hash: project_hash, line: line)
    hash[:project] = [project_hash]
    hash
  end

  # Attach the funding metadata
  def attach_funding(hash:, line:)
    return hash unless hash.present? && line.present?
    return hash unless line['funder_name'].present? || line['award_url'].present? || line['award_number'].present?

    award = process_award(line: line)
    award_type = award.downcase.start_with?('http') ? 'URL' : 'OTHER'

    hash[:funding] = [] unless hash[:funding].present?
    # Remove the funding and process it
    fundings = hash[:funding].select do |f|
      f.fetch(:grant_id, {})[:identifier] == award ||
        !f[:grant_id].present? && f[:name] == line['funder_name']
    end
    found = fundings.any?

    funding_hash = fundings.first || {}
    funding_hash = process_column(hash: funding_hash, line: line, column: 'funder_name', attr: :name)
    funding_hash[:grant_id] = { type: award_type, identifier: award } unless funding_hash[:grant_id].present?
    funding_hash[:funding_status] = funding_hash.present? ? 'granted' : 'planned'

    # Add the contributor if it is new
    hash[:funding] << funding_hash unless found
    hash
  end

  # Attach a related_identifier
  # rubocop:disable Metrics/CyclomaticComplexity
  def attach_related_identifier(hash:, value:, type: 'URL', descriptor: 'is_referenced_by')
    return hash unless value.present?

    hash[:extension] = [{}] unless hash[:extension].present?
    hash[:extension].first[:dmphub] = {} unless hash[:extension][:dmphub].present?
    hash[:extension].first[:dmphub][:related_identifiers] = [] unless hash[:extension].first[:dmphub][:related_identifiers].present?
    return hash if hash[:extension].first[:dmphub][:related_identifiers].select { |id| id[:value] == value }.any?

    value = value.start_with?('http') ? value : "https://doi.org/#{value}"

    hash[:extension].first[:dmphub][:related_identifiers] << {
      datacite_related_identifier_type: type, value: value, datacite_relation_type: descriptor
    }
    hash
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  # Attach a contributor's metadata
  def attach_contributor(hash:, line:)
    return hash unless hash.present? && line.present? && line['contributor_name'].present?

    role = process_role(line: line)
    orcid = process_orcid(line: line)

    hash[:contributor] = [] unless hash[:contributor].present?
    # Select the contributor
    contributors = hash[:contributor].select do |c|
      (c.fetch(:contributor_id, {})[:identifier] == orcid && orcid.present?) ||
        (c[:name] == line['contributor_name'])
    end
    found = contributors.any?

    contributor = contributors.first || { role: [] }
    contributor[:name] = line['contributor_name'] if line['contributor_name'].present? && !contributor[:name].present?
    contributor[:contributor_id] = { type: 'ORCID', identifier: orcid } unless contributor[:contributor_id].present?
    contributor[:role] << role unless contributor[:role].include?(role)
    contributor[:affiliation] = { name: process_affiliation(line: line) } if line['affiliation'].present? && !contributor[:affiliation].present?

    # Add the contributor if it is new
    hash[:contributor] << contributor unless found
    hash
  end

  def attach_dataset(hash:, line:)
    return hash unless hash.present? && line.present? && (line['dataset_doi'].present? || line['dataset_url'].present?)

    hash[:dataset] = [] unless hash[:dataset].present?
    datasets = hash[:dataset].select do |d|
      d = {} unless d.present?
      (d.fetch(:dataset_id, {})[:datacite_related_identifier_type] == 'DOI' && d.fetch(:dataset_id, {})[:identifier] == line['dataset_doi']) ||
        (d.fetch(:dataset_url, {})[:type] == 'URL' && d.fetch(:dataset_url, {})[:identifier] == line['dataset_url'])
    end
    return hash if datasets.any?

    dataset_hash = {
      title: "Dataset: #{line.fetch('dataset_doi', line['dataset_url']&.split('/')&.last)}",
      type: 'dataset'
    }
    if line['dataset_doi'].present?
      dataset_hash[:dataset_id] = { type: 'DOI', identifier: process_doi(doi: line['dataset_doi']) }
    else
      dataset_hash[:dataset_id] = { type: 'URL', identifier: line['dataset_url'] }
    end
    hash[:dataset] << dataset_hash unless hash[:dataset].include?(dataset_hash)
    hash
  end

  # Create the Contact based on the available Contributors with an Affiliation
  def handle_contacts(dmps: [])
    dmps = dmps.map do |dmp|
      contributors = dmp[:dmp].fetch(:contributor, []).select do |c|
        c[:role].include?('https://dictionary.casrai.org/Contributor_Roles/Data_curation') && c[:affiliation].present?
      end
      if contributors.empty?
        contributors = dmp[:dmp].fetch(:contributor, []).select do |c|
          c[:role].include?('https://dictionary.casrai.org/Contributor_Roles/Investigation') && c[:affiliation].present?
        end
      end
      if contributors.any?
        dmp[:dmp][:contact] = {
          name: contributors.first[:name],
          affiliation: {
            name: contributors.first.fetch(:affiliation, {})[:name]
          },
          contact_id: { type: 'ORCID', identifier: contributors.first[:contributor_id][:identifier] }
        }
      end
      dmp
    end
    dmps
  end

  # Retrieve the Award identifier
  def process_award(line:)
    return nil unless line.present?
    return line['award_url'] unless line['award_number'].present?

    nsf_base_url = 'https://www.nsf.gov/awardsearch/showAward?AWD_ID='
    nsf_funders = ['National Science Foundation', 'Division of Ocean Sciences',
                   'Division of Biological Infrastructure', 'Emerging Frontiers Office',
                   'Integrative Graduate Education and Research Traineeship',
                   'Division of Integrative Organismal Systems', 'Office of Polar Programs']

    return line.fetch('award_url', line['award_number']) unless nsf_funders.include?(line['funder_name'])
    return line['award_number'].gsub(/[A-Z]+\-/, nsf_base_url) if line['award_number'].present?

    line['award_url']
  end

  # Prepend the ORCID base URL if its missing
  def process_orcid(line:)
    return nil unless line.present? && line['orcid'].present?

    line['orcid'].start_with?('http') ? line['orcid'] : "https://orcid.org/#{line['orcid']}"
  end

  # Convert the Role to CASRAI
  def process_role(line:)
    default = 'https://dictionary.casrai.org/Contributor_Roles/Investigation'
    return default unless line['role'].present?

    case line['role']
    when %w[http://ocean-data.org/schema/PrincipalInvestigatorRole
            http://ocean-data.org/schema/Co-PrincipalInvestigatorRole]
      return default
    when 'http://ocean-data.org/schema/ContactRole'
      return 'https://dictionary.casrai.org/Contributor_Roles/Data_curation'
    end

    line['role'].start_with?('https://dictionary.casrai.org/Contributor_Roles/') ? line['role'] : default
  end

  # Safely convert a date
  def process_date(date:)
    return nil unless date.present?

    Date.parse(date).to_formatted_s(:iso8601)
  rescue ArgumentError => e
    return nil unless e.message.downcase == 'invalid date'

    Date.parse("#{date}-01").to_formatted_s(:iso8601)
  end

  def process_affiliation(line:)
    return nil unless line.present? && line['affiliation'].present?

    line['affiliation'].gsub(/\s+\(.*\)\s?$/, '')
  end

  # Prepend the DOI base URL
  def process_doi(doi:)
    return nil unless doi.present?

    doi.start_with?('http') ? doi : "https://doi.org/#{doi}"
  end
end
