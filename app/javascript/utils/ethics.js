// ***** Ethics Report Toggle via Ethical Component ***** //

function ethicalToggle () {
  if (ethicalCheckbox.checked === true) {
    ethicsReport.hidden = false
  } else {
    ethicsReport.hidden = true
  }
}

if (document.querySelector('#c-ethical')) {
  var ethicalCheckbox = document.querySelector('#c-ethical')
  var ethicsReport = document.querySelector('#c-ethicsreport')
  ethicalToggle()

  ethicalCheckbox.addEventListener('change', function () {
    ethicalToggle()
  })
}
