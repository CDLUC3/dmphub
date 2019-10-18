import initSectionHandlers from '../../utils/add_section';

const toggleEthicalDetails = ((selector, context) => {
  if ($(selector).find('option:selected').val() === 'yes' ) {
    $(context).show();
  } else {
    $(context).hide();
  }
});

const initEthicalIssues = () => {
  const ethicalIssues = $('#data_management_plan_ethical_issues');
  const ethicalDetails = $('.ethical-considerations');

  ethicalIssues.on('change', () => {
    toggleEthicalDetails(ethicalIssues, ethicalDetails);
  });

  toggleEthicalDetails(ethicalIssues, ethicalDetails);
};

/* Turbolinks caches assets, so ensure that the JS is reloaded even if
 * the page contents are pulled from the cache
 */
$(document).on('turbolinks:load', () => {
  initSectionHandlers();
  initEthicalIssues();
});
