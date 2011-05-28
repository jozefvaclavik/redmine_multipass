#MultiPass SSO Authentication plugin for Redmine (v 0.0.1)

This plugin is based on MultiPass gem (https://github.com/entp/multipass) and allows
users to login to the application with Single Sign On (SSO) link.
Configuration on both sides (Redmine and Custom app) is needed. Please read Configuration
instruction.

##Requirements
This plugin requires MultiPass gem installed.
<pre><code>
gem install multipass
</code></pre>


##Installation

<pre><code>
1. cd vendor/plugins; git clone git://github.com/user_name/name_of_the_plugin.git
2. cd ../..; rake db:migrate:plugins RAILS_ENV=production
3. restart redmine
</code></pre>

##Configuration

###Redmine:

* Enable => Enable/Disable plugin.
* Debug Mode => Enable/Disable debug mode. While enabled, instead of proceeding
  User information to login/register, decrypted information are displayed.
* Self Registration => Enalbe/Disable registration mode.
* Support Email => Contact information in case that SSO Auth will fail to login/register
* Group => User group, where newly created users will be added
* SSO Api Key => SSO Key for encryption/decryption
* Site Key => Site key used for encryption/decryption


###Custom app: EXAMPLE USSAGE
- In User.rb model:
**site_key and sso_api_key are string values from redmine settings**

<pre><code>
def self.multipass
  @multipass ||= MultiPass.new(site_key, sso_api_key)
end

def multipass
  users_remote_uid = "#{site_key}_#{id}"
  user_mail = "Obtain users email"
  user_first_name = "Obtain users first name"
  user_last_name = "Obtain users last name"
	user_login = "Obtain users login"
  self.class.multipass.encode(:email => user_mail, :first_name => user_first_name, :last_name => user_last_name, :login => user_login, :remote_uid => users_remote_uid, :expires => 30.minutes.from_now)
end
</code></pre>

- In your view:
**Assume that @user is currently logged in user**

<pre><code>
link_to( "Open Redmine", "http://link_to_your_redmine_app/multipass/?sso=#{CGI.escape(@user.multipass)}")
</code></pre>

Known issues
=======

So far, none :-)

Copyright (c) 2011 Jozef Vaclavik, released under the MIT license
