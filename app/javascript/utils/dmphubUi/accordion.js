// ***** Accordion Component ***** //

function accordion (accordionEls) {
  accordionEls.forEach(function (el, index) {
    if (index === 0) {
      el.open = true
    }

    el.addEventListener('click', function () {
      accordionEls.forEach(function (el) {
        if (el !== this) {
          el.open = false
        }
      }, this)
    })
  })
}

if (document.querySelector('.c-accordion')) {
  var fundingAccordionEls = document.querySelectorAll('#accordion-funding details')
  var datasetsAccordtionEls = document.querySelectorAll('#accordion-datasets details')
  var distributionAccordionEls = document.querySelectorAll('#accordion-distribution details')

  accordion(fundingAccordionEls)
  accordion(datasetsAccordtionEls)
  accordion(distributionAccordionEls)
}
