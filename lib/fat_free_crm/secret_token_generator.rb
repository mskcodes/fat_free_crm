# Copyright (c) 2008-2014 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------

require 'securerandom'

module FatFreeCRM

  class SecretTokenGenerator

    class << self

      #
      # If there is no secret token defined, we generate one and save it as a setting
      # If a token has been already been saved, we tell Rails to use it and move on.
      def setup!
        if token.blank?
          Rails.logger.info("No secret key defined yet... generating and saving to Setting.secret_token")
          generate_and_persist_token!
        end
        FatFreeCRM::Application.config.secret_token = token
        raise(FAIL_MESSAGE) if FatFreeCRM::Application.config.secret_token.blank?# and !Rails.env.test?
      end

      private

      FAIL_MESSAGE = ::I18n.t('secret_token_generator.fail_message', default: "There was a problem generating the secret token. Please see lib/fat_free_crm/secret_token_generator.rb")

      #
      # Read the current token from settings
      def token
        Setting.secret_token
      end

      #
      # Create a new secret token and save it as a setting.
      def generate_and_persist_token!
        quietly do
          Setting.secret_token = SecureRandom.hex(64)
        end
      end

      #
      # Yields to a block that executes with the logging turned off
      # This stops the secret token from being appended to the log
      def quietly(&block)
        temp_logger = ActiveRecord::Base.logger
        ActiveRecord::Base.logger = nil
        yield
        ActiveRecord::Base.logger = temp_logger
      end

    end

  end

end