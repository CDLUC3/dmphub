import initEthicalIssues from './ethical_issues';
import initFormValidations from './form_validation';
import initSectionHandlers from './add_section';

$(() => {
  /* Turbolinks caches assets, so ensure that the JS is reloaded even if
   * the page contents are pulled from the cache
   */
  $(document).on('turbolinks:load', () => {
    initEthicalIssues();
    initFormValidations();
    initSectionHandlers();
  });

  initEthicalIssues();
  initFormValidations();
  initSectionHandlers();
});
