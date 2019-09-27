$(() => {
  /* Ethical Issues */
  const ethicalIssues = $('#data_management_plan_ethical_issues');
  const ethicalDetails = $('.ethical-considerations');

  const toggleEthicalDetails = () => {
    if (ethicalIssues.find('option:selected').val() === 'yes' ) {
      ethicalDetails.show();
    } else {
      ethicalDetails.hide();
    }
  };

  ethicalIssues.on('change', () => {
    toggleEthicalDetails();
  });

  toggleEthicalDetails();
});
