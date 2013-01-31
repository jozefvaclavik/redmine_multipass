#WARNING! No longer under active development

Feel free to submit patches via pull requests. I will review them and merge.

For redmine 1.4 and older, see the right branch/tag, this one is suitable for 2.2

#MultiPass SSO Authentication plugin for Redmine (v 0.0.1)

This plugin is based on MultiPass gem (https://github.com/entp/multipass) and allows
users to register and login to the application with Single Sign On (SSO) link.
Configuration on both sides (Redmine and Custom app) is needed. Please read Configuration
instruction.

##Requirements
This plugin requires MultiPass gem installed.

<pre><code>gem install multipass</code></pre>

Edit your Gemfile and add there
<pre><code>gem 'multipass'</code></pre>

##Installation

<pre><code>1. cd plugins; git clone git://github.com/jozefvaclavik/redmine_multipass.git
2. cd ..; rake redmine:plugins:migrate RAILS_ENV=production
3. restart redmine</code></pre>

Because redmine from 1.4 version will not support wildchart routes, you need to add
your routes manually (I had same experience with Redmine 1.3.x). 

Edit config/routes.rb and add these four lines AFTER first line.
<pre><code>match 'multipass', :controller => 'multipass', :action => 'index'
match 'multipass/index', :controller => 'multipass', :action => 'index'
match 'multipass/successful_authentication', :controller => 'multipass', :action => 'successful_authentication'
match 'multipass/register', :controller => 'multipass', :action => 'register'</code></pre>

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

<pre><code>def self.multipass
  @multipass ||= MultiPass.new(site_key, sso_api_key)
end

def multipass
  users_remote_uid = "#{site_key}_#{id}"
  user_mail = "Obtain users email"
  user_first_name = "Obtain users first name"
  user_last_name = "Obtain users last name"
	user_login = "Obtain users login"
  self.class.multipass.encode(:email => user_mail, :first_name => user_first_name, :last_name => user_last_name, :login => user_login, :remote_uid => users_remote_uid, :expires => 30.minutes.from_now)
end</code></pre>

- In your view:
**Assume that @user is currently logged in user**

<pre><code>link_to( "Open Redmine", "http://link_to_your_redmine_app/multipass/?sso=#{CGI.escape(@user.multipass)}")</code></pre>

###PHP Support:
If your custom application is based on PHP, take a look at Tomdchi PHP version of multipass library. https://github.com/tomdchi/Redmine-PHP-MultiPass


Known issues
=======

So far, none :-)

Copyright (c) 2011 Jozef Vaclavik, released under the MIT license
