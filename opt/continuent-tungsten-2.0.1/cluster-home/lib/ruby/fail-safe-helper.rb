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
stopall="#{current_dir}/../../../cluster-home/bin/stopall"
stop_replicator="#{current_dir}/../../../tungsten-replicator/bin/replicator stop"
stop_manager="#{current_dir}/../../../tungsten-manager/bin/manager stop"
stop_connector="#{current_dir}/../../../tungsten-connector/bin/connector stop"

SUCCESS = 0
ERR_TUNGSTEN_STOPPED_DS_NOT_UPDT = 3
ERR_TUNGSTEN_NOT_STOPPED_DS_UPDT = 4
ERR_TUNGSTEN_NOT_STOPPED_DS_NOT_UPDT = 5

@manager_props = {}
@ds_props = {}
@store_success = true
@command_success = false

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
if ARGV.length == 0
  puts "Fail-safe operation - stopping Tungsten services"
  puts `#{stop_manager}`
  if ($?.to_i == 0)
    @command_success = true
  end
elsif ARGV.length == 1 && ARGV[0] == "true"
  puts "Fail-safe called from manager. No need to stop the manager."
  @command_success = true
end

@manager_props = load(manager_properties)

data_service = @manager_props["manager.gc.group"]

full_success = true
puts "Updating all datasources to fail-safe state"
Dir.glob("#{cluster_conf_dir}cluster/#{data_service}/datasource/*.properties").each do|ds|
  @ds_props = load(ds)
  # load(file) will set store success to false upon error
  if (@store_success == true)
    @ds_props["state"] = "SHUNNED"
    @ds_props["lastError"] = "Shunned by fail-safe procedure"
    @ds_props["lastShunReason"] = "FAILSAFE"
    @ds_props["vipIsBound"] = "false"
    @ds_props["isAvailable"] = "false"
    @store_success = store(@ds_props, ds)
  end
  full_success = full_success & @store_success
end

if (@command_success == true)
  if (full_success == true)
    puts "Fail-safe completed successfully"
    exit SUCCESS
  else
    puts "Fail-safe completed without updating data sources"
    exit ERR_TUNGSTEN_STOPPED_DS_NOT_UPDT
  end
else
  if (full_success == true)
    puts "Fail-safe completed without stopping manager service"
    exit ERR_TUNGSTEN_NOT_STOPPED_DS_UPDT
  else
    puts "Fail-safe completed without stopping manager service nor updating data sources"
    exit ERR_TUNGSTEN_NOT_STOPPED_DS_NOT_UPDT
  end
end
