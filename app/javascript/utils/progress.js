// ***** Progress Component ***** //

if (document.querySelector('.c-progress')) {
  var steps = document.querySelectorAll('.c-progress li')
  for (var i = 0; i < steps.length; i++) {
    if (steps[i].hasAttribute('aria-current')) {
      break
    }
    steps[i].classList.add('completed')
    steps[i].insertAdjacentHTML('afterbegin', '<span>Completed step: </span>')
  }
}
