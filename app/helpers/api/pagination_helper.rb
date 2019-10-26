# frozen_string_literal: true

module Api
  module PaginationHelper

    def url_without_pagination(url:)
      return url unless url.present? && url.is_a?(String)

      url = url.gsub(/per_page\=[\d]+/, '')
               .gsub(/page\=[\d]+/, '')
               .gsub(/(&)+$/, '').gsub(/\?$/, '')
      (url.include?('?') ? "#{url}&" : "#{url}?")
    end

    def prev_page_link(current_url:)
      "#{url_without_pagination(url: current_url)}page=#{@page - 1}&per_page=#{@per_page}"
    end

    def next_page_link(current_url:)
      "#{url_without_pagination(url: current_url)}page=#{@page + 1}&per_page=#{@per_page}"
    end

  end
end
