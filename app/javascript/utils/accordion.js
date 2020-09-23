// ***** Accordion Component ***** //
const initAccordion = (selector, collapsedOnLoad = false) => {
  const accordionEls = document.querySelectorAll(`${selector} details`);

  accordionEls.forEach((el, index) => {
    // Open the section unless collapsedOnLoad is true and this not the first section
    el.open = !collapsedOnLoad || (collapsedOnLoad && index === 0)

    el.addEventListener('click', () => {
      accordionEls.forEach((el) => {
        if (el !== this) {
          el.open = false
        }
      }, this);
    });
  });
};

export default initAccordion;
