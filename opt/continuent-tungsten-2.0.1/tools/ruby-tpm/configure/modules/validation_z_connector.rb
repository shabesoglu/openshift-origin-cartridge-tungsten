class ConnectorChecks < GroupValidationCheck
  include ClusterHostCheck
  
  def initialize
    super(CONNECTORS, "connector", "connectors")
    
    ConnectorCheck.submodules().each{
      |klass|
      
      self.add_check(klass.new())
    }
  end
  
  def set_vars
    @title = "Connector checks"
  end
end

module ConnectorCheck
  include GroupValidationCheckMember
  include ConnectorEnabledCheck
  
  def get_host_key(key)
    [HOSTS, @config.getProperty(get_member_key(DEPLOYMENT_HOST)), key]
  end
  
  def get_dataservice_key(key)
    ds_aliases = @config.getPropertyOr(get_member_key(DEPLOYMENT_DATASERVICE), [])
    return [DATASERVICES, ds_aliases.at(0), key]
  end
  
  def get_dataservice_alias
    if self.is_a?(HashPromptMemberModule)
      get_member()
    else
      ds_aliases = @config.getPropertyOr(get_member_key(DEPLOYMENT_DATASERVICE), [])
      return ds_aliases.at(0)
    end
  end
  
  def get_topology
    Topology.build(get_dataservice_alias(), @config)
  end
  
  def self.included(subclass)
    @submodules ||= []
    @submodules << subclass
  end

  def self.submodules
    @submodules || []
  end
end

class ConnectorSmartScaleAllowedCheck < ConfigureValidationCheck
  include ConnectorCheck
  
  def set_vars
    @title = "Connector SmartScale allowed check"
  end
  
  def validate
    if (@config.getProperty(get_member_key(CONN_SMARTSCALE)) == "true" &&
        @config.getProperty(get_member_key(CONN_RWSPLITTING)) == "true"
    )
      error("Both SmartScale and R/W Splitting are enabled.  You must disable one of them.")
    end
  end
end

class ConnectorListenerAddressCheck < ConfigureValidationCheck
  include ConnectorCheck
  
  def set_vars
    @title = "Connector listener address check"
  end
  
  def validate
    addr = @config.getProperty(get_member_key(CONN_LISTEN_ADDRESS))
    if addr.to_s() == ""
      error("Unable to determine the listening address for the connector")
    end
  end
end

class ConnectorRWROAddressesCheck < ConfigureValidationCheck
  include ConnectorCheck
  
  def set_vars
    @title = "Check that the connector r/w addresses and r/o addresses are different"
  end

  def validate
    rw_addresses = @config.getProperty(get_member_key(CONN_RW_ADDRESSES)).split(",")
    ro_addresses = @config.getProperty(get_member_key(CONN_RO_ADDRESSES)).split(",")

    rw_addresses.each{
      |address|
      if address == ""
        next
      end
      
      if ro_addresses.include?(address)
        error("#{address} appears in --connector-rw-addresses and --connector-ro-addresses")
      end
    }
    
    unless is_valid?()
      help("Redefine the --connector-rw-addresses and --connector-ro-addresses for this host or data service so that the values are unique")
    end
  end
  
  def enabled?
    super() && @config.getProperty(get_member_key(CONN_RW_ADDRESSES)).to_s != "" && @config.getProperty(get_member_key(CONN_RO_ADDRESSES)).to_s != ""
  end
end

class ConnectorUserCheck < ConfigureValidationCheck
  include ConnectorCheck
  
  def set_vars
    @title = "Connector User check"
  end
  
  def validate
    conuser = @config.getProperty('connector_user')
    repluser = @config.getProperty('repl_datasource_user')
   
      if conuser == repluser
        error("Connector User must be different from Datasource User")
        help("The Connector user and the Datasource user must be different users - Ensure the --connector-user parameter is specified")
      end
    
  end
end