require 'uri'
require 'net/http'
require 'json'
require 'base64'


module Openproject
  module ExtendsCreatesTicketArticles
    def article_create(ticket, params)
      super  # Ruft die ursprüngliche Implementierung auf
      Rails.logger.info "OpenProject Task"
      # Führen Sie nach der ursprünglichen Logik Ihre benutzerdefinierte Benachrichtigungslogik aus
      notify_openproject_if_applicable(ticket, params)
    end

    private

    def notify_openproject_if_applicable(ticket, params)
      if params[:type_id] == Ticket::Article::Type.lookup(name: 'openproject task').id
        begin
          # Ihre Benachrichtigungslogik hier
          Rails.logger.info "Start."
          clean_params = Ticket::Article.association_name_to_id_convert(params)
          clean_params = Ticket::Article.param_cleanup(clean_params, true)
          article = Ticket::Article.new(clean_params)

          assignee = find_user_by_email(article.to)
          Rails.logger.info "Assignee: #{assignee}"
          openproject_service = OpenprojectService.new
          body = {subject: "(Ticket#" + ticket.number + ") " + article.subject, description: {raw: article.body}, assignee: assignee, customField1: "Ticket#" + ticket.number}
          response = openproject_service.post("projects/3/work_packages", body)
          if response
            Rails.logger.info "Success."
          else 
            Rails.logger.error "Fehler bei der Kommunikation mit OpenProject workpackage."
          end
        end
      end
    end

    def find_user_by_email(email)

      openproject_service = OpenprojectService.new
      filter = [{ login: { operator: "=", values: [email] } }].to_json
      response = openproject_service.get("users", { filters: filter })
  
      if response
        elements = response.dig("_embedded", "elements")
        if elements&.any?
          user_self_link = elements[0].dig("_links", "self")
          Rails.logger.info "Benutzer Self-Link: #{user_self_link}"
          return user_self_link  # Rückgabe des Self-Link des ersten Benutzers
        else
          Rails.logger.info "Kein Benutzer mit der E-Mail #{email} gefunden."
        end
      else
        Rails.logger.error "Fehler bei der Kommunikation mit OpenProject mail."
      end
      nil
    end

  end
end
