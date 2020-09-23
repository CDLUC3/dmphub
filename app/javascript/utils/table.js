/* HTML tables */
$(document).on('turbolinks:load', () => {

  const enableSortAsc = (col) => {
    const sort_on = col.attr('data-sort-col');
    const dir = col.attr('data-sort-dir');
    const faIcon = col.find('.fa-caret-square-up, .fa-caret-square-down');

    if (faIcon != undefined && faIcon.length > 0) {
      faIcon.removeClass('fa-caret-square-down').addClass('fa-caret-square-up');
      faIcon.on('click', (e) => {

      });
    }
  };

  $('div.sortable').each((_idx, el) => {
    const col = $(el);

    if (col != undefined) {
      const sort_on = col.attr('data-sort-col');
      const dir = col.attr('data-sort-dir');

      if (sort_on != undefined && dir !== undefined) {
        const faIcon = col.find('.fa-caret-square-up, .fa-caret-square-down');
        const form = col.closest('.grid-table[data-href]');

        if (faIcon != undefined && form != undefined) {
          faIcon.on('click', (e) => {
            $.ajax(form.attr('data-href'))
              .done((data) => {
                alert(`SUCCESS: ${data}`);
              })
              .fail((xhr) => {
                alert(`ERROR: ${data}`);
              });
          });
        }
        console.log(`Found sortable column: ${sort_on}, ${dir}`);
        console.log(faIcon);
      }
    }
  });
});
