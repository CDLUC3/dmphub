// ***** Other Staff Component ***** //

// Append form element attribute values (no matter how named) from <template> with counter number:
function appendElAttributes (formEls) {
  formEls.forEach(function (el) {
    if (el.hasAttribute('aria-label')) {
      el.setAttribute('aria-label', el.getAttribute('aria-label') + ' ' + counter)
    }
    if (el.hasAttribute('id')) {
      el.setAttribute('id', el.getAttribute('id') + counter)
    }
    if (el.hasAttribute('name')) {
      el.setAttribute('name', el.getAttribute('name') + counter)
    }
    if (el.hasAttribute('for')) {
      el.setAttribute('for', el.getAttribute('for') + counter)
    }
  })
}

// Give focus to first label from the last fieldgroup for accessibility:
function focusFirstLabel () {
  if (document.querySelector('.c-other__fieldgroup')) {
    var firstLabel = document.querySelector('.c-other__fieldgroup:last-child label')
    firstLabel.focus()
  }
}

if (document.querySelector('.c-other')) {
  var fields = document.querySelector('.c-other__fields')
  var fieldGroups = document.querySelectorAll('.c-other__fieldgroup')
  var buttonAdd = document.querySelector('#button-add')
  var counter = 0

  // If any fieldgroups exist from a previous session on page load, create array of numbers from fieldgroup aria-label text, get the highest number in the array, then start the counter from that number:
  if (fieldGroups.length > 0) {
    var fieldGroupNumbers = [].map.call(fieldGroups, function (el) {
      return el.getAttribute('aria-label').replace(/\D/g, '')
    })

    var highestNumber = Math.max.apply(Math, fieldGroupNumbers)
    counter = highestNumber
  }

  buttonAdd.addEventListener('click', function () {
    // Increment counter by 1, copy instance of <template> contents, append <template> form element attributes with counter number:
    counter++
    var template = document.querySelector('template').content
    template = document.importNode(template, true)

    var groupLabel = template.querySelectorAll('.c-other__fieldgroup')
    var inputs = template.querySelectorAll('input')
    var selects = template.querySelectorAll('select')
    var textareas = template.querySelectorAll('textarea')
    var labels = template.querySelectorAll('label')

    appendElAttributes(groupLabel)
    appendElAttributes(inputs)
    appendElAttributes(selects)
    appendElAttributes(textareas)
    appendElAttributes(labels)

    // Add copied <template> instance to .c-other__fields <div>:
    fields.appendChild(template)

    focusFirstLabel()

    // Recalculate all instances of fieldgroups to remove:
    fieldGroups = document.querySelectorAll('.c-other__fieldgroup')

    // Remove specific fieldgroup containing its remove button on click:
    fieldGroups.forEach(function (el) {
      el.querySelector('.e-button3').addEventListener('click', function () {
        this.parentElement.remove()
        focusFirstLabel()
      })
    })
  })
}
