# frozen_string_literal: true

# Helper methods for Sortable tables
module SortHelper
  def sort_link(column:, current_sort_col:, current_dir:, search:)
    dir = column == current_sort_col && current_dir == 'asc' ? 'desc' : 'asc'
    path = "#{sort_path}?sort_col=#{column}&sort_dir=#{dir}"
    path = search.present? ? path + "&search_words=#{search}" : path

    caret = 'sort' if column != current_sort_col
    caret = dir == 'desc' ? 'sort-up' : 'sort-down' unless caret.present?

    link_to icon('fas', caret), path, remote: true, aria: { hidden: true },
                                      title: 'Click to sort by this column'
  end
end
