default_action :install

property :gem_name, [String]
property :version, [String, NilClass], default: nil
property :user, [String], default: 'root'
property :ruby_string, [String], required: true

action :install do
  unless rvm.gemset?(ruby_string)
    Chef::Log.debug('Create gemset before installing gem')
    rvm.gemset_create(ruby_string)
  end

  if rvm.gem?(ruby_string, gem_name, version)
    Chef::Log.debug("Gem #{gem_name} #{version} already installed on gemset #{ruby_string} for user #{user}.")
  else
    Chef::Log.debug("Install gem #{gem_name} #{version} on gemset #{ruby_string} for user #{user}.")
    rvm.gem_install(ruby_string, gem_name, version)
    updated_by_last_action(true)
  end
end

%i[update uninstall].each do |action_name|
  action action_name do
    if rvm.gem?(ruby_string, gem_name, version)
      Chef::Log.debug "#{action_name.to_s.capitalize} gem #{gem_name} #{version} from gemset #{ruby_string} for user #{user}."
      updated_by_last_action(true)
    else
      Chef::Log.debug "Gem #{gem_name} #{version} is not installed on gemset #{ruby_string} for user #{user}."
    end
  end
end

action_class.class_eval do
  include ChefRvmCookbook::RvmResourceHelper
end
