import consumer from "./consumer"

$(document).on('turbolinks:load', () => {
  const doi = $('#related_works_channel');
  const streamTarget = $('[data-channel="related_works"]');

  if (doi.length > 0 && doi.val().length > 0 && streamTarget.length > 0) {
    consumer.subscriptions.create({ channel: 'RelatedWorksChannel', doi: doi.val() }, {
      connected() {
        // Called when the subscription is ready for use on the server
        this.perform('follow', { message_id: doi.val() });
      },

      received(data) {
        // Called when there's incoming data on the websocket for this channel
        streamTarget.append(`<li>${data['message']}</li>`);

        // The job will send a `done` flag to indicate that we can disconnect
        if (data['done']) {
          this.unsubscribe();
          this.perform('unfollow', { message_id: doi.val() });
        }
      }
    });
  }
});
