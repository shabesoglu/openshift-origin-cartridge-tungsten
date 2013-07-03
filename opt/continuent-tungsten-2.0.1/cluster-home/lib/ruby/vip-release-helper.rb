#!/usr/bin/env ruby
#
# TUNGSTEN SCALE-OUT STACK
# Copyright (C) 2010 Continuent, Inc.
# All rights reserved
#

require 'date'

current_dir=File.expand_path(File.dirname(__FILE__))
cluster_conf_dir="#{current_dir}/../../conf/"
manager_properties="#{current_dir}/../../../tungsten-manager/conf/manager.properties"
@manager_props = {}
@ds_props = {}
@store_success = true

SUCCESS = 0
ERR_VIP_WAS_NOT_BOUND = 255
ERR_VIP_NOT_ENABLED = 1
ERR_VIP_BOUND_RELEASE_ERROR = 3
ERR_VIP_BOUND_RELEASE_FAILED = 4
ERR_OTHER = 5

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
rescue
  @store_success = false
end

# Write properties to a file.  We use signal protection to avoid getting
# interrupted half-way through.
# Return true upon success, false otherwise
def store(props, properties_filename)
  # Protect I/O with trap for Ctrl-C.
  interrupted = false
  old_trap = trap("INT") {
    interrupted = true;
  }

  # Write.
  File.open(properties_filename, 'w') do |file|
    file.printf "# Tungsten configuration properties\n"
    file.printf "# Date: %s\n", DateTime.now
    props.sort.each do | key, value |
      file.printf "%s=%s\n", key, value
    end
  end

  # Check for interrupt and restore handler.
  if (interrupted)
    puts ("Fail-safe interrupted")
    return false;
  else
    trap("INT", old_trap);
    return true
  end
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

ds = "#{cluster_conf_dir}cluster/#{data_service}/datasource/#{data_source}.properties"
@ds_props = load(ds)

if @store_success == false
  puts "No data source is currenty defined for #{data_source}"
  puts "Cannot release VIP without configuration information"
  exit ERR_OTHER
end
interface = @ds_props["vipInterface"]

# check that ifconfig works fine
`#{sudo} #{ifconfig}`
command_works = ($?.to_i == 0)
if (!command_works)
  puts "Command \"#{sudo} #{ifconfig}\" failed - check sudo access and ifconfig path"
  exit ERR_OTHER
end

# check current interface status
status = `#{sudo} #{ifconfig} #{interface} 2>&1`
interface_bound = status.include? "inet "
if ($?.to_i != 0)
  puts "Could not check interface status. ifconfig output was: #{status}"
  exit ERR_OTHER
end
if (!interface_bound)
  puts "No action taken: interface #{interface} was not bound. ifconfig output was: #{status}"
  exit ERR_VIP_WAS_NOT_BOUND
end

command = "#{sudo} #{ifconfig} #{interface} down 2>&1"

puts "Releasing VIP with command: #{command}"
command_output = `#{command}`
if ($?.to_i != 0)
  command_failed = true
end

status = `#{sudo} #{ifconfig} #{interface}`
interface_bound = status.include? "inet "
if (interface_bound)
  if (command_failed == false)
    puts "Unknown error: ifconfig succeeded but interface still bound. Command output was #{command_output}"
    exit ERR_VIP_BOUND_RELEASE_FAILED
  else
    puts "ifconfig failed, interface still bound. Command output was #{command_output}"
    exit ERR_VIP_BOUND_RELEASE_ERROR
  end
end

if (command_failed)
  puts "VIP successfully released but ifconfig failed with unknown error. Output was #{command_output}"
  exit ERR_OTHER
end

puts "VIP successfully released"

vip_release_success = true

# load(file) will set store success to false upon error
if (@store_success == true)
  puts "Updating #{ds} vip status to vipIsBound=false"
  @ds_props["vipIsBound"] = "false"
  @store_success = store(@ds_props, ds)
end
if @store_success == true
  exit SUCCESS
else
  exit ERR_OTHER
end
