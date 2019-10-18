import debounce from './debouncer';

/* gather all of the pertinent typeahead elements */
const establishContext = (element) => {
  const target = $(element)

  return {
    textField: $(element).find('.typeahead'),
    idField: $(element).find('input[type="hidden"]'),
    suggestions: $(element).find('ul'),
  };
};

/* unescaped HTML */
const decodeHtml = (string) => {
  return string.replace(/&amp;/g, '&')
               .replace(/&apos;/g, '\'')
               .replace(/&quot;/g, '"')
               .replace(/&lt;/g, '<')
               .replace(/&gt;/g, '>');
};

/* Sort the ajax results by the display values */
const sortOptions = (array) => {
  if (array) {
    return array.sort((a, b) => {
      const first = a.value.toUpperCase();
      const second = b.value.toUpperCase();
      return (first < second ? -1 : (first > second ? 1 : 0));
    });
  } else {
    return []
  }
};

/* Convert the ajax results into list items */
const arrayToOptions = (array) => {
  return sortOptions(array).map((obj) => {
    return `<li data-id="${obj.id}" role="option" aria-selected="false" tabindex="-1">${obj.value}</li>`;
  });
};

/* Update the typeahead text field and hidden id when the user selects something */
const handleSelection = (context, selected) => {
  const target = $(selected);
  context.textField.val(decodeHtml(target.html()));
  context.idField.val(target.attr('data-id'));
  context.suggestions.hide();
};

/* User canceled from the suggestion list */
const handleEscape = (context) => {
  $(context.textField).focus();
  $(context.suggestions).hide();
};

const highlightSuggestion = (listItem) => {
  $(listItem).addClass('current-suggestion');
};

const unhighlightSuggestion = (listItem) => {
  $(listItem).removeClass('current-suggestion');
};

const navigateSuggestions = (context, keyCode, listItem = null) => {
  if (listItem) {
    const current = $(listItem);

    switch (keyCode) {
      case 13:
        /* User pressed the enter key (selected option by keyboard) */
        handleSelection(context, listItem);
        break;

      case 27:
        /* User pressed the escape key (closed options by keyboard) */
        handleEscape(context);
        break;

      case 38:
        /* User pressed the up arrow so move to the prior item */
        unhighlightSuggestion(current);
        const prior = current.prev();
        if (prior.length) {
          highlightSuggestion($(prior).focus());
        } else {
          handleEscape(context);
        }
        break;

      case 40:
        /* User pressed the down arrow so move to the next item */
        unhighlightSuggestion(current);
        const sibling = current.next()
        if (sibling.length) {
          highlightSuggestion($(sibling).focus());
        } else {
          handleEscape(context);
        }
        break;
    }
  }
};

/* Make the ajax call to retrieve the search results */
const typeahead = (element) => {
  const context = establishContext(element.parent('.js-typeahead'));

  $.ajax({
    url: `${$(context.textField).attr('data-source')}?q=${$(context.textField).val()}`,
  }).done((data) => {
    context.suggestions.html(arrayToOptions(data));
    context.suggestions.show();

  }).fail((err) => {
    console.log(err);
  });

};

const initTypeaheadFields = () => {

  $.each($('.js-typeahead'), (idx, el) => {
    const context = establishContext(el);

    /* Debounce the ajax calls so that we are nice API consumers */
    const debounced = debounce(() => {
      typeahead(context.textField);
    }, 300);

    /* User has modified or entered the typeahead search */
    $(context.textField).on('keyup', (e) => {
      if (debounced.length) {
        debounced.cancel;
      }
      debounced();
    }).on('keydown', (e) => {
      /* If the user pressed the down arrow, move into the suggestion list */
      if (e.keyCode == 40) {
        /* Navigate into the suggestion list */
        $(context.suggestions).find('li:first-child').focus();
      }
    });

    /* User navigated away from the typeahead */
    $(el).on('blur', (e) =>{
      handleEscape(context);
    });

    /* User has pressed a key while on one of the suggestions */
    $(el).on('keydown', 'li', (e) => {
      /* The user has pressed a key while on one of the suggestions */
      navigateSuggestions(context, e.keyCode, e.target);
    }).on('click', 'li', (e) => {
      /* User selected an option via mouse */
      handleSelection(context, e.target);
    });

    /* Hide the suggestions on page load */
    $(context.suggestions).hide();
  })
};

export default initTypeaheadFields;
