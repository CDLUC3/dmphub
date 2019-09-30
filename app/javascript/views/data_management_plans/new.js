import initEthicalIssues from './ethical_issues';
import initFormValidations from './form_validation';
import initSectionHandlers from './add_section';

$(() => {

  $(document).on('turbolinks:load', () => {
    initEthicalIssues();
    initFormValidations();
    initSectionHandlers();
  });

  initEthicalIssues();
  initFormValidations();
  initSectionHandlers();
});
