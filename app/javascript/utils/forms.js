/* Required fields */

var dirty = false;

const requiredField = (selector) => {
  return $(`#${$(selector).attr('for')}`);
};

const validateField = (context) => {
  if (!$(context).val()) {
    $(context).addClass('error');
    return false;
  } else {
    $(context).removeClass('error');
    return true;
  }
};

const clearErrors = (context) => {
  $.each($('.error'), (idx, el) => {
    $(el).removeClass('error');
  });
  $('.form-message').html('');
};

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

const initForms = () => {
  $('body').on('change', 'form input, form select, form textarea', (e) => {
    dirty = true;
  });

  /* Only allow form submission if all requirements are met */
  $('body').on('submit', 'form', (e) => {
    clearErrors(e.target);

    if (!validateRequirements(e.target)) {
      /* Required fields were not completed */
      e.preventDefault();
      return false;

    } else {
      return true;
    }
  });

  /* If the user clicks one of the nav elements then validate the required fields and
     then submit the form */
  $('body').on('click', 'nav.c-progress a, nav.c-progress li', (e) => {
    const form = $(e.target).parent().siblings('form');
    e.preventDefault();
    if (validateRequirements(form)) {
      form.submit();
    }
    //return false;
  });

};

export default initForms;
