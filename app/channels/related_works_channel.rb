# frozen_string_literal: true

# A channel used to take a given DOI and locate any related workss from the pidGraph.
# The results are then combined with the known relatedIdentifiers and converted
# into citations before being returned to the client.
class RelatedWorksChannel < ApplicationCable::Channel
  def subscribed
    # params[:doi] comes from the JS when the page loads
    stream_from params[:doi]
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end
end
