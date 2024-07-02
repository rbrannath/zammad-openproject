# config/initializers/extend_creates_ticket_articles.rb
Rails.application.config.to_prepare do
  Rails.logger.info "Prepend Openproject"
  CreatesTicketArticles.prepend Openproject::ExtendsCreatesTicketArticles
end
