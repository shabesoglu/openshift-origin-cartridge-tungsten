#!/usr/bin/env ruby 
#
# TUNGSTEN SCALE-OUT STACK
# Copyright (C) 2010 Continuent, Inc.
# All rights reserved
#

current_dir=File.expand_path(File.dirname(__FILE__))
cluster_conf_dir="#{current_dir}/../../conf/"
manager_properties="#{current_dir}/../../../tungsten-manager/conf/manager.properties"
@manager_props = {}
@ds_props = {}

SUCCESS = 0
ERR_VIP_WAS_NOT_BOUND = 1
ERR_VIP_NOT_ENABLED = 2
ERR_VIP_BOUND_RELEASE_ERROR = -1
ERR_VIP_BOUND_RELEASE_FAILED = -2
ERR_OTHER = -3

# Read properties from a file. 
def load(properties_filename)
  new_props = {}
  File.open(properties_filename, 'r') do |file|
    file.read.each_line do |line|
      line.strip!
      if (line =~ /^([\w\.]+)\s*=\s*(\S.*)/)
        key = $1
        value = $2
        new_props[key] = value
      end
    end 
  end
  return new_props
end

# Compares string with various "true" formats
def isTrue(value)
  if (value == nil)
    return false
  end
  return value.match(/(true|t|yes|y|1)$/i) != nil
end

# Main
@manager_props = load(manager_properties)
vip_enabled = @manager_props["vip.isEnabled"]

if (!isTrue(vip_enabled))
  puts "VIP not enabled - quitting!"
  exit ERR_VIP_NOT_ENABLED
end

data_service = @manager_props["manager.gc.group"]
data_source = @manager_props["manager.gc.member"]
sudo = @manager_props["manager.sudoCommandPrefix"]
ifconfig = @manager_props["vip.ifconfig_path"]

@ds_props = load("#{cluster_conf_dir}cluster/#{data_service}/datasource/#{data_source}.properties")
interface = @ds_props["vipInterface"]

# check that ifconfig works fine
`#{sudo} #{ifconfig}`
command_works = ($?.to_i == 0)
if (!command_works)
  puts "Command \"#{sudo} #{ifconfig}\" failed - check sudo access and ifconfig path"
  exit ERR_OTHER
end

# check current interface status
status = `#{sudo} #{ifconfig} #{interface}`
interface_bound = status.include? "inet "
if (interface_bound)
  puts "interface #{interface} is bound. ifconfig output was #{status}"
  exit 0 
end

exit 1
