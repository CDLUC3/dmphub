/* Required fields */

var dirty = false;

const requiredField = (selector) => {
  return $(`#${$(selector).attr('for')}`);
}

const validateField = (context) => {
  if (!$(context).val()) {
    $(context).addClass('error');
    return false;
  } else {
    $(context).removeClass('error');
    return true;
  }
}

const validateRequirements = (context) => {
  var requirementsMet = true;
  $.each($(context).find('.required'), (idx, el) => {
    const input = requiredField(el);

    if (!validateField(input)) {
      requirementsMet = false;
    }
  });
  return requirementsMet;
};

const displayFormErrors = (message) => {
  $('.alert').html(message);
}
const clearFormErrors = () => {
  $('.alert').html('');
}

const displayFormSuccess = (message) => {
  $('.notice').html(message);
}
const clearFormSuccess = () => {
  $('.notice').html('');
}

const initFormValidations = () => {
  $('form input, form select, form textarea').on('blur', (e) => {
    if (dirty) {
      $(e.currentTarget).parent('form').submit();
    }
  }).on('change', (e) => {
    dirty = true;
  });

  /* Only allow form submission if all requirements are met */
  $('form').submit((e) => {
    clearFormErrors();

    if (!validateRequirements(e.currentTarget)) {
      /* Required fields were not completed */
      e.preventDefault();
      displayFormErrors('You must fill out all of the required fields!');
      return false;

    } else {
      return true;
    }
  }).on('ajax:error', (e) => {
    clearFormSuccess();
    displayFormErrors(e.detail[0]['message']);

  }).on('ajax:success', (e) => {
    clearFormErrors();
    displayFormSuccess(e.detail[0]['message']);
  });
};

export default initFormValidations;
