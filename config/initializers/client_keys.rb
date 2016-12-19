keys = YAML.load_file(Rails.root.join('config', 'clients.yml'))

WellmatchAccounts::Application.config.client_public_keys = keys
