/* Create a new copy of the section and increment the ids */
const cloneSection = (sectionNumber, section) => {
  const clone = $(section).clone();
  $.each($(clone).children('input, select, label'), (idx, el) => {
    const target = $(el);

    if (target.attr('for')) {
      const label = target.attr('for');
      target.attr('for', label.replace(`_0_`, `_${sectionNumber}_`))
    } else {
      const id = target.attr('id');
      const name = target.attr('name');
      target.attr('id', id.replace(`_0_`, `_${sectionNumber}_`))
      target.attr('name', name.replace(`[0]`, `[${sectionNumber}]`))
    }
  });
  return clone
};

/* Gets the next available section */
const prepareSection = (container, template) => {
  const target = $(template);
  const sectionCount = $(container).children('.association-entry').length;
  const clone = cloneSection(sectionCount, target);
  clone.removeClass('association-template').addClass('association-entry');
  container.append(clone);
  clone.show();
};

/* Adds another section to an association */
const addSection = (context) => {
  const container = $(context).parent('.association');
  const template = container.find('.association-template');
  prepareSection(container, template);
};

const removeSection = (context) => {
  $(context).parent('.association-entry').remove();
};

const initSectionHandlers = () => {
  $('.association').on('click', '.add-association-button', (e) => {
    addSection(e.target);
  });

  $('.association').on('click', '.remove-association', (e) => {
    removeSection(e.target);
  });

  /* Hide all section templates by default */
  $('.association .association-template').hide();

  console.log('loading sections');
};

export default initSectionHandlers;
