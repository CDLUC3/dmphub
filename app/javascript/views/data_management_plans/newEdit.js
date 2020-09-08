import initSectionHandlers from '../../utils/addSection';

const toggleEthicalDetails = ((selector, context) => {
  if ($(selector).is(':checked')) {
    $(context).show();
  } else {
    $(context).hide();
  }
});

/* When the user checks the ethical_issues box, show the report and description fields */
const initEthicalIssues = () => {
  const ethicalIssues = $('#data_management_plan_ethical_issues');
  const ethicalDetails = $('#c-ethicsreport');

  $('body').on('change', '#data_management_plan_ethical_issues', () => {
    toggleEthicalDetails(ethicalIssues, ethicalDetails);
  });

  toggleEthicalDetails(ethicalIssues, ethicalDetails);
};

const unlinkOrcid = (selector) => {
  const button = $(selector);
  button.siblings('a').remove();
  $('#contact_value').attr('type', 'text').show();
  button.remove();
};

/* Turbolinks caches assets, so ensure that the JS is reloaded even if
 * the page contents are pulled from the cache
 */
$(document).on('turbolinks:load', () => {
  initSectionHandlers();
  initEthicalIssues();

  /* Remove the ORCID fields from the DOM and replace with a textbox when the user
   * clicks the unlink/remove ORCID button
   */
  $('body').on('click', '#remove-orcid', (e) => {
    unlinkOrcid(e.target);
  });

  $('#contact_value').hide();
});
