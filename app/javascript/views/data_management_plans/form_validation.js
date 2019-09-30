/* Required fields */
const requiredFields = [
  $('#data_management_plan_title'),
  $('#data_management_plan_projects_attributes_0_start_on'),
  $('#data_management_plan_projects_attributes_0_end_on'),
  $('.primary-contact #contact_name'),
  $('.primary-contact #contact_email'),
  $('.primary-contact #contact_value'),
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

  if (requirementsMet) {
    /* Validate any DM Staff entries */
    if (!validateAssociation('.dm-staff-form')) {
      requirementsMet = false;
    }
  }

  return requirementsMet;
};

const validateAssociation = (context) => {
  /* Loop through each section and check its required fields */
  $.each($(context).find('.association-template'), (idx, section) => {
    if ($(section).css('display') === 'block') {
      var empty = true;
      $.each($(section).find('.required'), (idx, el) => {
        if (!validateField(el) && !empty) {
          return false
        }
      });
    }
  });
  return true;
};

const removeAssociationTemplates = (context) => {
  $(context).find('.association-template').remove();
};

const initFormValidations = () => {
  /* keep the project and DMP titles synced */
  $('#data_management_plan_title').on('keyup', (e) => {
    const el = $(e.currentTarget);
    $('#data_management_plan_projects_attributes_0_title').val(el.val());
  });

  /* validate the field has a value */
  $.each(requiredFields, (idx, el) => {
    $(el).on('keydown', () => {
      validateField(el);
    });
  });

  /* Only allow form submission if all requirements are met */
  $('form[action="/data_management_plan"]').submit((e) => {
    if (!validateRequirements()) {
      console.log('preventing');
      /* Required fields were not completed */
      e.preventDefault();
      return false;

    } else {
      removeAssociationTemplates(e.target);
    }
  });

  console.log('loading form validations');
};

export default initFormValidations;
