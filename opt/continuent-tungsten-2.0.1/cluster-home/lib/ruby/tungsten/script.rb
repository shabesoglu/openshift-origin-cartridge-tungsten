module TungstenScript
  NAGIOS_OK=0
  NAGIOS_WARNING=1
  NAGIOS_CRITICAL=2
  
  def run
    main()
    cleanup(0)
  end
  
  def initialize
    # Does this script required to run against an installed Tungsten directory
    @require_installed_directory = true
    
    # Definition of each command that this script will support
    @command_definitions = {}
    
    # The command, if any, the script should run
    @command = nil
    
    # Definition of each option that this script is expecting as input
    @option_definitions = {}
    
    # The command-line arguments of all options that have been defined
    # This is used to identify duplicate arguments
    @option_definition_arguments = {}
    
    # The collected option values from the script input
    @options = {}
    
    TU.debug("Begin #{$0} #{ARGV.join(' ')}")
    
    begin
      configure()
    
      if TU.display_help?()
        display_help()
        cleanup(0)
      end
    
      parse_options()
    
      unless TU.is_valid?()
        cleanup(1)
      end
    
      TU.debug("Options:")
      @options.each{
        |k,v|
        TU.debug("    #{k} => #{v}")
      }
    
      validate()
    
      unless TU.is_valid?()
        cleanup(1)
      end
    rescue => e
      TU.exception(e)
      cleanup(1)
    end
  end
  
  def command
    @command
  end
  
  def configure
  end
  
  def opt(option_key, value = nil)
    if value != nil
      @options[option_key] = value
    end
    
    return @options[option_key]
  end
  
  def add_command(command_key, definition)
    begin
      command_key = command_key.to_sym()
      if @command_definitions.has_key?(command_key)
        raise "The #{command_key} command has already been defined"
      end

      if definition[:default] == true
        if @command != nil
          raise "Multiple commands have been specified as the default"
        end
        @command = command_key
      end

      @command_definitions[command_key] = definition
    rescue => e
      TU.exception(e)
    end
  end
  
  def add_option(option_key, definition, &parse)
    begin
      option_key = option_key.to_sym()
      if @option_definitions.has_key?(option_key)
        raise "The #{option_key} option has already been defined"
      end

      unless definition[:on].is_a?(Array)
        definition[:on] = [definition[:on]]
      end
      
      # Check if the arguments for this option overlap with any other options
      definition[:on].each{
        |arg|
        
        arg = arg.split(" ").shift()
        if @option_definition_arguments.has_key?(arg)
          raise "The #{arg} argument is already defined for this script"
        end
        @option_definition_arguments[arg] = true
      }

      if parse != nil
        definition[:parse] = parse
      end

      if definition.has_key?(:default)
        opt(option_key, definition[:default])
      end

      @option_definitions[option_key] = definition
    rescue => e
      TU.exception(e)
    end
  end
  
  def parse_options
    if @command_definitions.size() > 0 && TU.remaining_arguments.size() > 0
      if @command_definitions.has_key?(TU.remaining_arguments[0].to_sym())
        @command = TU.remaining_arguments.shift()
      end
    end
    
    opts = OptionParser.new()
    
    @option_definitions.each{
      |option_key,definition|
      
      args = definition[:on]
      opts.on(*args) {
        |val|
                
        if definition[:parse] != nil
          begin
            val = definition[:parse].call(val)
            
            unless val == nil
              opt(option_key, val)
            end
          rescue MessageError => me
            TU.error(me.message())
          end
        else  
          opt(option_key, val)
        end
      }
    }
    
    TU.run_option_parser(opts)
  end
  
  def parse_integer_option(val)
    val.to_i()
  end
  
  def parse_float_option(val)
    val.to_f()
  end
  
  def parse_boolean_option(val)
    if val == "true"
      true
    elsif val == "false"
      false
    else
      raise MessageError.new("Unable to parse value '#{val}'")
    end
  end
  
  def validate
    if require_installed_directory?()
      if TI == nil
        TU.error("Unable to run #{$0} without the '--directory' argument pointing to an active Tungsten installation")
      else
        TI.inherit_path()
      end
    end
    
    if @command_definitions.size() > 0 && @command == nil
      TU.error("A command was not given for this script. Valid commands are #{@command_definitions.keys().join(', ')} and must be the first argument.")
    end
  end
  
  def display_help
    unless description() == nil
      TU.output(TU.wrapped_lines(description()))
      TU.output("")
    end
    
    TU.display_help()
    
    if @command_definitions.size() > 0
      TU.write_header("Script Commands", nil)
      
      @command_definitions.each{
        |command_key,definition|
        
        if definition[:default] == true
          default = "default"
        else
          default = ""
        end
        
        TU.output_usage_line(command_key.to_s(), definition[:help], default)
      }
    end
    
    TU.write_header("Script Options", nil)
    
    @option_definitions.each{
      |option_key,definition|
      
      if definition[:help].is_a?(Array)
        help = definition[:help].shift()
        additional_help = definition[:help]
      else
        help = definition[:help]
        additional_help = []
      end
      
      TU.output_usage_line(definition[:on].join(","),
        help, definition[:default], nil, additional_help.join("\n"))
    }
  end
  
  def require_installed_directory?(v = nil)
    if (v != nil)
      @require_installed_directory = v
    end
    
    @require_installed_directory
  end
  
  def description(v = nil)
    if v != nil
      @description = v
    end
    
    @description || nil
  end
  
  def script_log_path
    nil
  end
  
  def cleanup(code = 0)
    if TU.display_help?() != true && script_log_path() != nil
      File.open(script_log_path(), "w") {
        |f|
        TU.log().rewind()
        f.puts(TU.log().read())
      }
    end
    
    TU.debug("Finish #{$0} #{ARGV.join(' ')}")
    exit(code)
  end
  
  def nagios_ok(msg)
    puts "OK: #{msg}"
    cleanup(NAGIOS_OK)
  end
  
  def nagios_warning(msg)
    puts "WARNING: #{msg}"
    cleanup(NAGIOS_WARNING)
  end
  
  def nagios_critical(msg)
    puts "CRITICAL: #{msg}"
    cleanup(NAGIOS_CRITICAL)
  end
end