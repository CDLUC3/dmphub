// Generic spinner for ajax requests
$(document).on('turbolinks:load', () => {

  $('body').on('ajax:send', () => {
    // $('.spinner').show();
  }).on('ajax:complete', () => {
    // $('.spinner').hide();
  });

  $('.spinner').hide();

});
