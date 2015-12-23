# [START lookup_games]
require "google/api_client"

class LookupGameDetailsJob < ActiveJob::Base
  queue_as :default

  def perform game
    Rails.logger.info "(#{game.id}) Lookup game details for #{game.title.inspect}"

    # Create Games API client
    api_client = Google::APIClient.new application_name: "Gameshelf Sample Application"
    api_client.authorization = nil # Games API does not require authorization
    games_api = api_client.discovered_api "games"

    result = api_client.execute(
      api_method: games_api.volumes.list,
      parameters: { q: game.title, order_by: "relevance" } # what is the default order?  can we leave off "relevance" and get consistently good results?
    )

    # Lookup a list of relevant games based on the provided game title.
    volumes = result.data.items
# [END lookup_games]

    # [START choose_volume]
    # To provide the best results, find the first returned game that
    # includes title and author information as well as a game cover image.
    best_match = volumes.find {|volume|
      info = volume.volume_info
      info.title && info.authors && info.image_links.try(:thumbnail)
    }

    volume = best_match || volumes.first
    # [END choose_volume]

    # [START update_game]
    if volume
      info   = volume.volume_info
      images = info.image_links

      publication_date = info.published_date
      publication_date = "#{$1}-01-01" if publication_date =~ /^(\d{4})$/
      publication_date = Date.parse publication_date

      game.author       = info.authors.join(", ") unless game.author.present?
      game.published_on = publication_date        unless game.published_on.present?
      game.description  = info.description        unless game.description.present?
      game.image_url    = images.try(:thumbnail)  unless game.image_url.present?
      game.save
    end
    # [END update_game]

    Rails.logger.info "(#{game.id}) Complete"
  end
end
# [END game_lookup]

__END__

New (Upcoming) Alpha google-api-client API

require "google/apis/games_v1"

GamesAPI = Google::Apis::GamesV1

class LookupGameDetailsJob < ActiveJob::Base
  queue_as :default

  def perform game
    puts "Lookup details for game #{game.id} #{game.title.inspect}"

    game_service = GamesAPI::GamesService.new
    game_service.authorization = Google::Auth.get_application_default [GamesAPI::AUTH_BOOKS]

    game_service.list_volumes game.title, order_by: "relevance" do |results, error|
      # TODO clean up error condition
      if error
        puts "ERROR!"
        puts error
        puts error.inspect
        raise "GameService list_volumes ERROR!"
      end

      volumes = results.application

      best_match = volumes.find {|volume|
        info = volume.volume_info
        info.title && info.authors && info.image_links.try(:thumbnail)
      }

      volume = best_match || volumes.first

      if volume
        info   = volume.volume_info
        images = info.image_links

        game.author       = info.authors.join(", ") unless game.author.present?
        game.published_on = info.published_date     unless game.published_on.present?
        game.description  = info.description        unless game.description.present?
        game.image_url    = images.try(:thumbnail)  unless game.image_url.present?
        game.save
      end
    end
  end
end
