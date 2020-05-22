# frozen_string_literal: true

module Api
  module V0
    # Helper to convert common JSON elements
    class ConversionService
      class << self
        # Converts a boolean field to [yes, no, unknown]
        def boolean_to_yes_no_unknown(value)
          return 'yes' if [true, 1].include?(value)

          return 'no' if [false, 0].include?(value)

          'unknown'
        end

        # Converts a [yes, no, unknown] field to boolean (or nil)
        def yes_no_unknown_to_boolean(value)
          return true if value&.downcase == 'yes'

          return nil if value.blank? || value&.downcase == 'unknown'

          false
        end

        # Returns the name of this application
        def local_provenance
          ApplicationService.application_name
        end

        # Translates RDA Common Standard identifier categories
        def to_rda_identifier_category(category:)
          case category
          when 'credit'
            'CRediT'
          else
            category.upcase
          end
        end

        # Translates identifier categories to RDA Common Standard
        def to_identifier_category(rda_category:)
          case rda_category
          when 'CRediT'
            'credit'
          else
            rda_category.downcase
          end
        end

        # Convert from a role to the CRediT URL
        def to_credit_taxonomy(role:)
          "https://dictionary.casrai.org/Contributor_Roles/#{role.capitalize}"
        end

        # Convert from a CRediT URL to a role
        def from_credit_taxonomy(role:)
          role.split('/').last.downcase
        end

        # Converts a User to a Person
        def user_to_person(user:, role:)
          return {} unless user.present? && user.is_a?(User)

          person = Person.find_by_orcid(user.orcid)
          return PersonDataManagementPlan.new(person: person, role: role) if person.present?

          person = Person.find_or_initialize_by(name: user.name, email: user.email)
          person.identifiers << Identifier.find_or_initialize_by(
            provenance: local_provenance, category: 'orcid', value: user.orcid,
            identifiable_type: 'Person'
          )
          PersonDataManagementPlan.new(person: person, role: role)
        end

        def languages
          %w[aar abk afr aka amh ara arg asm ava ave aym aze
             bak bam bel ben bih bis bod bos bre bul
             cat ces cha che chu chv cor cos cre cym
             dan deu div dzo
             ell eng epo est eus ewe
             fao fas fij fin fra fry ful
             gla gle glg glv grn guj
             hat hau hbs heb her hin hmo hrv hun hye
             ibo ido iii iku ile ina ind ipk isl ita jav jpn
             kal kan kas kat kau kaz khm kik kin kir kom kon kor kua kur
             lao lat lav lim lin lit ltz lub lug
             mah mal mar mkd mlg mlt mon mri msa mya
             nau nav nbl nde ndo nep nld nno nob nor nya
             oci oji ori orm oss
             pan pli pol por pus
             que
             roh ron run rus
             sag san sin slk slv sme smo sna snd som sot spa sqi srd srp ssw sun swa swe
             tah tam tat tel tgk tgl tha tir ton tsn tso tuk tur twi
             uig ukr urd uzb
             ven vie vol
             wln wol
             xho
             yid yor
             zha zho zul].freeze
        end

        def currency_codes
          %w[aed afn all amd ang aoa ars aud awg azn
             bam bbd bdt bgn bhd bif bmd bnd bob brl bsd btn bwp byn bzd
             cad cdf chf clp cny cop crc cuc cup cve czk
             djf dkk dop dzd
             egp ern etb eur
             fjd fkp
             gbp gel ggp ghs gip gmd gnf gtq gyd
             hkd hnl hrk htg huf
             idr ils imp inr iqd irr isk
             jep jmd jod jpy
             kes kgs khr kmf kpw krw kwd kyd kzt
             lak lbp lkr lrd lsl lyd
             mad mdl mga mkd mmk mnt mop mru mur mvr mwk mxn myr mzn
             nad ngn nio nok npr nzd
             omr
             pab pen pgk php pkr pln pyg
             qar
             ron rsd rub rwf
             sar sbd scr sdg sek sgd shp sll sos spl* srd stn svc syp szl
             thb tjs tmt tnd top try ttd tvd twd tzs
             uah ugx usd uyu uzs
             vef vnd vuv
             wst
             xaf xcd xdr xof xpf
             yer
             zar zmw zwd].freeze
        end

        def pid_systems
          %w[ark arxiv bibcode doi ean13 eissn handle igsn isbn issn istc lissn
						 lsid pmid purl upc url urn other].freeze
        end

        def geo_locations
          %w[ad ae af ag ai al am ao aq ar as at au aw ax az
             ba bb bd be bf bg bh bi bj bl bm bn bo bq br bs bt bv bw by bz
             ca cc cd cf cg ch ci ck cl cm cn co cr cu cv cw cx cy cz
             de dj dk dm do dz
             ec ee eg eh er es et
             fi fj fk fm fo fr
             ga gb gd ge gf gg gh gi gl gm gn gp gq gr gs gt gu gw gy
             hk hm hn hr ht hu
             id ie il im in io iq ir is it
             je jm jo jp
             ke kg kh ki km kn kp kr kw ky kz
             la lb lc li lk lr ls lt lu lv ly
						 ma mc md me mf mg mh mk ml mm mn mo mp mq mr ms mt mu mv mw mx my mz
             na nc ne nf ng ni nl no np nr nu nz
             om
             pa pe pf pg ph pk pl pm pn pr ps pt pw py
             qa
						 re ro rs ru rw
             sa sb sc sd se sg sh si sj sk sl sm sn so sr ss st ssv sx sy sz
             tc td tf tg th tj tk tl tm tn to tr tt tv tw tz
             ua ug um us uy uz
             va vc ve vg vi vn vu
             wf ws
             ye yt
             za zm zw].freeze
        end

        def certifications
          %w[din31644 dini-zertifikat dsa iso16363 iso16919 trac wds coretrustseal].freeze
      end
    end
  end
end
