import initForms from '../../utils/forms';
import initTypeaheadFields from '../../utils/typeahead';

$(document).on('turbolinks:load', () => {
  initForms();
  initTypeaheadFields();

  /* Re-initialize the typeaheads after an ajax call */
  $('body').on('ajax:complete', (e) => {
    initTypeaheadFields();
  });
});
/*
$(() => {
  $('body').on('ajax:complete', (e) => {

console.log('bar');

    initTypeaheadFields();
  });
});
*/