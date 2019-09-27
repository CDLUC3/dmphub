$(() => {
  /* Required fields */
  const contactName = $('.primary-contact #contact_name');
  const contactEmail = $('.primary-contact #contact_email');
  const contactOrcid = $('.primary-contact #contact_value');
  const requiredFields = [
    $('#data_management_plan_title'),
    $('#data_management_plan_projects_attributes_0_start_on'),
    $('#data_management_plan_projects_attributes_0_end_on'),
  ];

  const validateField = (context) => {
    if (!$(context).val()) {
      $(context).addClass('error');
      return false;
    } else {
      $(context).removeClass('error');
      return true;
    }
  }

  const validateRequirements = () => {
    var requirementsMet = true;

    $.each(requiredFields, (idx, el) => {
      if (!validateField(el)) {
        requirementsMet = false;
      }
    });

    return requirementsMet;
  };

  /* keep the project and DMP titles synced */
  $('#data_management_plan_title').on('keyup', (e) => {
    const el = $(e.currentTarget);
    $('#data_management_plan_projects_title').val(el.val());
  });

  /* validate the field has a value */
  $.each(requiredFields, (idx, el) => {
    $(el).on('keydown', () => {
      validateField(el);
    });
  });

  /* Only allow form submission if all requirements are met */
  $('form').submit((e) => {
    if (validateRequirements()) {

    } else {
      console.log('preventing');
      /* Required fields were not completed */
      e.preventDefault();
      return false;
    }
  });
});
