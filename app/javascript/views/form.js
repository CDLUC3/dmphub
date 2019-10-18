import initForms from '../../utils/forms';
import initTypeaheadFields from '../../utils/typeahead';

$(document).on('turbolinks:load', () => {
  initForms();
  initTypeaheadFields();
});
