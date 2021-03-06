class RestartCommand
  include ConfigureCommand
  include RemoteCommand
  include ClusterCommandModule
  
  unless Configurator.instance.is_locked?()
    include RequireDataserviceArgumentModule
  end
  
  def skip_prompts?
    true
  end
  
  def display_alive_thread?
    false
  end
  
  def get_validation_checks
    [
      ActiveDirectoryIsRunningCheck.new(),
      CurrentTopologyCheck.new()
    ]
  end
  
  def get_deployment_object_modules(config)
    [
      RestartClusterDeploymentStep
    ]
  end
  
  def self.get_command_name
    'restart'
  end
  
  def self.get_command_description
    "Restart Tungsten services on the machines specified or this installation."
  end
end

module RestartClusterDeploymentStep
  def get_methods
    [
      ConfigureCommitmentMethod.new("stop_services", -1, 0),
      ConfigureCommitmentMethod.new("start_services", 1, ConfigureDeployment::FINAL_STEP_WEIGHT),
      ConfigureCommitmentMethod.new("wait_for_manager", 2, -1),
      ConfigureCommitmentMethod.new("report_services", ConfigureDeployment::FINAL_GROUP_ID, ConfigureDeployment::FINAL_STEP_WEIGHT, false)
    ]
  end
  module_function :get_methods
end