class NeedListener
                  
  def initialize
    @marples = Messenger.instance.client  
  end
  
  def listen
    Signal.trap('TERM') do
      client.close
      exit
    end
    
    listen_on_updated
    @marples.join
  end                                  
  
  def listen_on_updated
    @marples.when 'need-o-tron', 'needs', 'updated' do |need|
      logger.info "Found need #{need}"

      begin
        logger.info "Processing need `#{need['title']}`"

        artefact = Artefact.find_by_need_id(need['id'])
        logger.info "Found artefact `#{artefact.name}` in Panopticon"

        require 'gds_api/needotron'
        api = GdsApi::Needotron.new(Plek.current.environment)
        need_data = api.need_by_id(need['id'])
        logger.info "Getting need information from `#{need['id']}`"

        artefact.department = need_data.writing_team.name rescue nil
        artefact.fact_checkers = need_data.fact_checkers.collect{ |e| e.fact_checker.email }.join(', ')
        artefact.save!
        logger.info "----> Saved `#{artefact.name}` with department `#{artefact.department}` and fact checkers `#{artefact.fact_checkers}`"
      rescue => e
        logger.error "Unable to process message #{need}"
        logger.error [e.message, e.backtrace].flatten.join("\n")
      end

      logger.info "Finished processing `#{need}`"
    end

    logger.info 'Listening for updated objects in Needotron'
  end

  def logger
    @logger ||= Rails.logger
  end
end