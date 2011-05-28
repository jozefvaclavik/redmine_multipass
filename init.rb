require 'redmine'
require 'dispatcher'
require 'multipass'
 
Redmine::Plugin.register :redmine_multipass do
  name 'A MultiPass SSO Authentication plugin'
  author 'Jozef Vaclavik'
  url 'http://github.com/jozefvaclavik/redmine_multipas' if respond_to?(:url)
  description 'A MultiPass SSO Authentication'
  version '0.0.1'

  settings :partial => 'settings/redmine_multipass_settings',
    :default => {
      'enable' => 'true',
      'debug' => 'false',
      'autoregistration' => 'true',
      'supportemail' => '',
      'group_id' => '',
      'sso_api_key' => '',
      'site_key' => ''
    }
end

Dispatcher.to_prepare do
end