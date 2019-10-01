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

export default initEthicalIssues;