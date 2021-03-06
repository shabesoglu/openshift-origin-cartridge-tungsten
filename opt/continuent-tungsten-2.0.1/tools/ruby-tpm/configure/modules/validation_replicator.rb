require 'socket'

class ReplicatorChecks < GroupValidationCheck
  include ClusterHostCheck
  
  def initialize
    super(REPL_SERVICES, "replication service", "replication services")
    
    ReplicationServiceValidationCheck.submodules().each{
      |klass|
      
      self.add_check(klass.new())
    }
  end
  
  def set_vars
    @title = "Replication service checks"
  end
end

module ReplicationServiceValidationCheck
  include GroupValidationCheckMember
  include ReplicatorEnabledCheck
  
  def get_applier_datasource
    ConfigureDatabasePlatform.build([@parent_group.name, get_member()], @config)
  end
  
  def get_extractor_datasource
    get_applier_datasource()
  end
  
  def get_host_key(key)
    [HOSTS, @config.getProperty(get_member_key(DEPLOYMENT_HOST)), key]
  end
  
  def get_dataservice
    if self.is_a?(HashPromptMemberModule)
      get_member()
    else
      @config.getPropertyOr(get_member_key(DEPLOYMENT_DATASERVICE), nil)
    end
  end
  
  def get_topology
    Topology.build(get_dataservice(), @config)
  end
  
  def get_dataservice_key(key)
    return [DATASERVICES, get_dataservice(), key]
  end
  
  def get_applier_key(key)
    get_member_key(key)
  end
  
  def get_extractor_key(key)
    get_member_key(key)
  end
  
  def self.included(subclass)
    @submodules ||= []
    @submodules << subclass
  end

  def self.submodules
    @submodules || []
  end
end

module CreateServiceCheck
end

module ModifyServiceCheck
  def enabled?
    false
  end
end

class THLDirectoryWriteableCheck < ConfigureValidationCheck
  include ReplicationServiceValidationCheck
  
  def set_vars
    @title = "THL directory writeable check"
  end
  
  def validate
    dir = @config.getProperty(get_member_key(REPL_LOG_DIR))
    unless File.writable?(dir)
      if File.exists?(dir)
        if File.directory?(dir)
          error("Unable to write to the THL directory (#{dir})")
        else
          error("The THL directory (#{dir}) is a file")
        end
      else
        begin
          FileUtils.mkdir_p(dir)
          FileUtils.rmdir(dir)
        rescue => e
          error("Unable to create the THL directory (#{dir})")
          error(e.message)
        end
      end
    end
  end
end

class RelayDirectoryWriteableCheck < ConfigureValidationCheck
  include ReplicationServiceValidationCheck
  
  def set_vars
    @title = "Relay directory writeable check"
  end
  
  def validate
    dir = @config.getProperty(get_member_key(REPL_RELAY_LOG_DIR))
    unless File.writable?(dir)
      if File.exists?(dir)
        if File.directory?(dir)
          error("Unable to write to the relay directory (#{dir})")
        else
          error("The relay directory (#{dir}) is a file")
        end
      else
        begin
          FileUtils.mkdir_p(dir)
          FileUtils.rmdir(dir)
        rescue => e
          error("Unable to create the relay directory (#{dir})")
          error(e.message)
        end
      end
    end
  end
end

class BackupDumpDirectoryWriteableCheck < ConfigureValidationCheck
  include ReplicationServiceValidationCheck
  
  def set_vars
    @title = "Backup temp directory writeable check"
  end
  
  def validate
    dir = @config.getProperty(get_member_key(REPL_BACKUP_DUMP_DIR))
    unless File.writable?(dir)
      if File.exists?(dir)
        if File.directory?(dir)
          error("Unable to write to the backup temp directory (#{dir})")
        else
          error("The backup temp directory (#{dir}) is a file")
        end
      else
        begin
          FileUtils.mkdir_p(dir)
          FileUtils.rmdir(dir)
        rescue => e
          error("Unable to create the backup temp directory (#{dir})")
          error(e.message)
        end
      end
    end
  end
  
  def enabled?
    super() && @config.getProperty(get_member_key(REPL_BACKUP_METHOD)) != "none"
  end
end

class BackupDirectoryWriteableCheck < ConfigureValidationCheck
  include ReplicationServiceValidationCheck
  
  def set_vars
    @title = "Backup storage directory writeable check"
  end
  
  def validate
    dir = @config.getProperty(get_member_key(REPL_BACKUP_STORAGE_DIR))
    unless File.writable?(dir)
      if File.exists?(dir)
        if File.directory?(dir)
          error("Unable to write to the backup storage directory (#{dir})")
        else
          error("The backup storage directory (#{dir}) is a file")
        end
      else
        begin
          FileUtils.mkdir_p(dir)
          FileUtils.rmdir(dir)
        rescue => e
          error("Unable to create the backup storage directory (#{dir})")
          error(e.message)
        end
      end
    end
  end
  
  def enabled?
    super() && @config.getProperty(get_member_key(REPL_BACKUP_METHOD)) != "none"
  end
end

class BackupScriptAvailableCheck < ConfigureValidationCheck
  include ReplicationServiceValidationCheck
  
  def set_vars
    @title = "Backup script availability check"
  end
  
  def validate    
    if File.executable?(@config.getProperty(get_member_key(REPL_BACKUP_SCRIPT)))
      info("The backup script is executable")
    else
      if File.exists?(@config.getProperty(get_member_key(REPL_BACKUP_SCRIPT)))
        error("The backup script (#{@config.getProperty(get_member_key(REPL_BACKUP_SCRIPT))}) is not executable")
      else
        error("The backup script (#{@config.getProperty(get_member_key(REPL_BACKUP_SCRIPT))}) does not exist")
      end
    end
  end
  
  def enabled?
    super() && @config.getProperty(get_member_key(REPL_BACKUP_METHOD)) == "script"
  end
end

class THLStorageCheck < ConfigureValidationCheck
  include ReplicationServiceValidationCheck
  
  def set_vars
    @title = "THL storage check"
    self.extend(NotTungstenUpdateCheck)
  end
  
  def validate
    repl_log_dir = @config.getProperty(get_member_key(REPL_LOG_DIR))
    if repl_log_dir
      if File.exists?(repl_log_dir) && !File.directory?(repl_log_dir)
        error("Replication log directory #{repl_log_dir} already exists as a file")
      elsif File.exists?(repl_log_dir)
        dir_file_count = cmd_result("ls #{repl_log_dir} | wc -l")
        if dir_file_count.to_i() > 0
          error("Replication log directory #{repl_log_dir} already contains log files")
        end
      end
    end
    
    begin
      thl_schema = "tungsten_"+@config.getProperty(DATASERVICENAME)
      get_applier_datasource.check_thl_schema(thl_schema)
    rescue => e
      error(e.message)
    end
  end
end

class ServiceTransferredLogStorageCheck < ConfigureValidationCheck
  include ReplicationServiceValidationCheck
  include CreateServiceCheck
  
  def set_vars
    @title = "Service transferred log storage check"
    self.extend(NotTungstenUpdateCheck)
  end
  
  def validate
    if File.exists?(@config.getProperty(get_member_key(REPL_RELAY_LOG_DIR)))
      dir_file_count = cmd_result("ls #{@config.getProperty(get_member_key(REPL_RELAY_LOG_DIR))} | wc -l")
      if dir_file_count.to_i() > 0
        error("Transferred log directory #{@config.getProperty(get_member_key(REPL_RELAY_LOG_DIR))} already contains log files")
      end
    end
  end
  
  def enabled?
    super() && @config.getProperty(get_member_key(REPL_RELAY_LOG_DIR)).to_s != ""
  end
end

class DifferentMasterSlaveCheck < ConfigureValidationCheck
  include ReplicationServiceValidationCheck
  
  def set_vars
    @title = "Different master/slave datasource check"
  end
  
  def validate
    if (extractor = get_extractor_datasource())
      if extractor == get_applier_datasource()
        error("Service '#{@config.getProperty(get_member_key(DEPLOYMENT_SERVICE))}' uses the same datasource for extracting and applying events")
      end
    end
  end
end

class RMIListenerAddressCheck < ConfigureValidationCheck
  include ReplicationServiceValidationCheck
  
  def set_vars
    @title = "RMI listener address check"
  end
  
  def validate
    addr = @config.getProperty(get_member_key(REPL_RMI_ADDRESS))
    if addr.to_s() == ""
      error("Unable to determine the listening address for RMI operations")
    end
  end
end

class THLListenerAddressCheck < ConfigureValidationCheck
  include ReplicationServiceValidationCheck
  
  def set_vars
    @title = "THL listener address check"
  end
  
  def validate
    addr = @config.getProperty(get_member_key(REPL_SVC_THL_ADDRESS))
    if addr.to_s() == ""
      error("Unable to determine the listening address for THL operations")
    end
  end
end

class ParallelReplicationCountCheck < ConfigureValidationCheck
  include ReplicationServiceValidationCheck
  
  def set_vars
    @title = "Parallel replication count check"
  end
  
  def validate
    p = @config.getPromptHandler().find_prompt(get_member_key(REPL_SVC_CHANNELS))
    host_channels = @config.getNestedProperty(get_member_key(REPL_SVC_CHANNELS))
    ds_channels = p.get_default_value()
    
    if host_channels != nil && host_channels != ds_channels
      error("You are trying to configure this host with a custom replication channels setting.  That is not currently supported.  Please update the host configuration with --channels=#{ds_channels}")
    end
  end
end

class DatasourceBootScriptCheck < ConfigureValidationCheck
  include ReplicationServiceValidationCheck
  
  def set_vars
    @title = "Datasource boot script check"
  end
  
  def validate
    script = @config.getProperty(get_applier_key(REPL_BOOT_SCRIPT))
    if script.to_s() == ""
      error("There is no value for --datasource-boot-script")
      return
    end
    
    unless File.executable?(script)
      if File.exists?(script)
        error("The service script #{script} is not executable")
      else
        error("The service script #{script} does not exist")
      end
      help("Try providing a value for --datasource-boot-script")
    else
      if @config.getProperty(get_host_key(ROOT_PREFIX)) == "true"
        begin
          # Test if this script can be run via sudo w/o actually running it
          cmd_result("sudo -l #{script}")
        rescue CommandError
          error("Unable to run 'sudo #{script}'")
          help("Update the /etc/sudoers file or disable sudo by adding --enable-sudo-access=false")
        end
        
        if is_valid?()
          begin
            cmd_result("sudo #{script} status")
          rescue CommandError
            error("Unable to run 'sudo #{script} status' or the database server is not running")
            help("Update the /etc/sudoers file or disable sudo by adding --enable-sudo-access=false")
          end
        end
      else
        begin
          cmd_result("#{script} status")
        rescue CommandError
          warning("Unable to run '#{script} status' or the database server is not running")
        end
      end
    end
  end
  
  def enabled?
    return (super() && (get_topology().use_management?() || 
      (@config.getPropertyOr(get_member_key(REPL_BACKUP_METHOD), "") =~ /xtrabackup/))
    )
  end
end

class ParallelReplicationCheck < ConfigureValidationCheck
  include ReplicationServiceValidationCheck
  
  def set_vars
    @title = "Parallel replication consistency check"
  end
  
  def validate
    ptype = @config.getProperty(get_member_key(REPL_SVC_PARALLELIZATION_TYPE))
    channels = @config.getProperty(get_member_key(REPL_SVC_CHANNELS))
    
    if ptype == "none" and channels != "1"
      error("Parallelization type is set to 'none' but channels are set to #{channels}; either set parallelization type to 'disk' or 'memory' using --svc-parallelization-type or set channels to 1 using --channels")
    elsif ptype == "memory"
      warning("The 'memory' parallelization type is not recommended for production use; use 'disk' instead")
    end
  end
end
