#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

sub get_cfg
{
    my ($fname) = @_;
    my $cfg = slurp($fname);
    $cfg =~ s/:/=>/g;
    $cfg = '$cfg=' . $cfg;
    eval $cfg;
    if ($@)
    {
        die "error evaluating contents of $fname\n";
    }
    return $cfg;
}

my $deploy_cfg = get_cfg('./sor/deploy.cfg');
my $tungsten_cfg = get_cfg('./sor/tungsten.cfg');

$Data::Dumper::Indent = 1;

print Data::Dumper ->Dump([$deploy_cfg, $tungsten_cfg], ['deploy','tungsten']);


sub slurp
{
    my ($filename) = @_;
    open my $FH , '<', $filename
        or die "can't open $filename\n";
    my @lines = <$FH>;
    close $FH;
    if (wantarray)
    {
        return @lines;
    }
    else
    {
        my $text ='';
        $text .= $_ for @lines;
        chomp $text;
        return $text;
    }
}
sub fill_from_deploy_cfg
{
    my ($options, $deploy_cfg) = @_;
    my %user_values;
    my %deployment_info;
    my %server_list;

    for my $ds (keys %{ $deploy_cfg->{dataservices }})
    {
        if ($deploy_cfg->{dataservices}{$ds}{dataservice_composite_datasources})
        {
            $user_vales{COMPOSITE_DS}=$ds;
            $deployment_info->{composite_ds} = $ds;
        }
    }
    unless (exists $deploy_cfg->{'__defaults__'})
    {
        die "can't get defaults from deploy.cfg\n";
    }
    my %corresponding_defaults= (
        MYSQL_CONF                  => 'repl_datasource_mysql_conf',
        DATASOURCE_BOOT_SCRIPT      => 'repl_datasource_boot_script',
        MYSQL_BINARY_LOG_DIRECTORY  => 'repl_datasource_log_directory',
        USER                        => '',
        DATASOURCE_PORT             => '',
        
        
    );
    for my $item (keys %corresponding_defaults)
    {
        $user_vales->{$item}= $deploy_cfg->{'__defaults__'}{$item};
    }
    my $user_values = (
    'SLAVES1' => 'qa.tx2.continuent.com',
    'MORE_OPTIONS' => '--mgr-listen-interface=eth1 --backup-directory=/var/continuent/backups --repl-backup-method=xtrabackup',
    'MYSQL_BINARY_LOG_DIRECTORY' => '/var/lib/mysql',
    'NODE3' => 'qa.tx3.continuent.com',
    'DATASOURCE_BOOT_SCRIPT' => '/etc/init.d/mysql ',
    'ROOT_COMMAND' => 'true',
    'DS_NAME1' => 'europe',
    'CONTINUENT_ROOT' => '/opt/continuent/cookbook_test',
    'WITNESS' => 'qa.tx8.continuent.com',
    'SLAVES' => 'qa.tx2.continuent.com,qa.tx3.continuent.com',
    'SLAVES2' => 'qa.tx8.continuent.com',
    'DS_NAME' => 'lonelycluster',
    'CONNECTORJ' => '/opt/continuent/mysql-connector-java-5.1.16-bin.jar',
    'CONNECTOR_DIRECT_RO' => '127.0.0.2',
    'DATASOURCE_USER' => 'tungsten',
    'DATASOURCE_PASSWORD' => 'secret',
    'NODE4' => 'qa.tx8.continuent.com',
    'MASTER2' => 'qa.tx3.continuent.com',
    'MASTER1' => 'qa.tx1.continuent.com',
    'NODE1' => 'qa.tx1.continuent.com',
    'MASTER' => 'qa.tx1.continuent.com'
    );
}

__END__
$options = {
  'verbose' => 1,
  'manual' => 0,
  'force_uninstall' => 0,
  'collect_logs' => 0,
  'server_list' => {
    'relays' => [],
    'connectors_rw' => [],
    'masters' => [
      'qa.tx1.continuent.com'
    ],
    'connectors_ro' => [],
    'slaves' => [
      'qa.tx2.continuent.com',
      'qa.tx3.continuent.com'
    ],
    'connectors' => [
      'qa.tx2.continuent.com',
      'qa.tx8.continuent.com'
    ]
  },
  'skip_install' => 1,
  'display_options' => 0,
  'skip_load_test' => 1,
  'cookbook_directory' => './cookbook',
  'help' => 0,
  'debug' => 1,
  'log' => 1,
  'list' => 0,
  'show' => 0,
  'template' => 'std.tmpl',
  'uninstall_cluster' => 0,
  'version' => 0,
  'dry_run' => 0,
  'user_values' => {
    'COMPOSITE_DS' => 'world',
    'CONNECTORS1' => 'qa.tx1.continuent.com,qa.tx2.continuent.com',
    'WITNESS1' => 'qa.tx8.continuent.com',
    'CONNECTOR_DIRECT_RW' => '127.0.0.1',
    'NODE2' => 'qa.tx2.continuent.com',
    'MYSQL_CONF' => '/etc/my.cnf',
    'CONNECTORS2' => 'qa.tx3.continuent.com,qa.tx8.continuent.com',
    'DS_NAME2' => 'asia',
    'START_OPTION' => '--start-and-report',
    'USER' => 'tungsten',
    'DATASOURCE_PORT' => '3306',
    'CONNECTORS' => 'qa.tx2.continuent.com,qa.tx8.continuent.com',
    'WITNESS2' => 'qa.tx8.continuent.com',
    'SLAVES1' => 'qa.tx2.continuent.com',
    'MORE_OPTIONS' => '--mgr-listen-interface=eth1 --backup-directory=/var/continuent/backups --repl-backup-method=xtrabackup',
    'MYSQL_BINARY_LOG_DIRECTORY' => '/var/lib/mysql',
    'NODE3' => 'qa.tx3.continuent.com',
    'DATASOURCE_BOOT_SCRIPT' => '/etc/init.d/mysql ',
    'ROOT_COMMAND' => 'true',
    'DS_NAME1' => 'europe',
    'CONTINUENT_ROOT' => '/opt/continuent/cookbook_test',
    'WITNESS' => 'qa.tx8.continuent.com',
    'SLAVES' => 'qa.tx2.continuent.com,qa.tx3.continuent.com',
    'SLAVES2' => 'qa.tx8.continuent.com',
    'DS_NAME' => 'lonelycluster',
    'CONNECTORJ' => '/opt/continuent/mysql-connector-java-5.1.16-bin.jar',
    'CONNECTOR_DIRECT_RO' => '127.0.0.2',
    'DATASOURCE_USER' => 'tungsten',
    'DATASOURCE_PASSWORD' => 'secret',
    'NODE4' => 'qa.tx8.continuent.com',
    'MASTER2' => 'qa.tx3.continuent.com',
    'MASTER1' => 'qa.tx1.continuent.com',
    'NODE1' => 'qa.tx1.continuent.com',
    'MASTER' => 'qa.tx1.continuent.com'
  },
  'log_file' => 'tungsten-cookbook.log',
  'skip_vars' => undef,
  'more_options' => undef,
  'run_test' => 1,
  'cctrl_options' => '',
  'tests' => undef,
  'cluster_info' => {
    'connectors_rw' => [],
    'relays' => [],
    'masters' => [
      'MASTER'
    ],
    'connectors_ro' => [],
    'slaves' => [
      'SLAVES'
    ],
    'connectors' => [
      'CONNECTORS'
    ]
  },
  'fail_on_undefined' => 0,
  'deployment_info' => {
    'lonelycluster' => {
      'masters' => [
        'qa.tx1.continuent.com'
      ],
      'slaves' => [
        'qa.tx2.continuent.com',
        'qa.tx3.continuent.com'
      ],
      'connectors' => [
        'qa.tx2.continuent.com',
        'qa.tx8.continuent.com'
      ]
    }
  },
  'values_file' => './cookbook/USER_VALUES.sh'
};

$deploy = {
  'hosts' => {
    'qa_tx1_continuent_com' => {
      'host_name' => 'qa.tx1.continuent.com'
    },
    'qa_tx8_continuent_com' => {
      'host_name' => 'qa.tx8.continuent.com'
    },
    'qa_tx2_continuent_com' => {
      'host_name' => 'qa.tx2.continuent.com'
    },
    'qa_tx3_continuent_com' => {
      'host_name' => 'qa.tx3.continuent.com'
    }
  },
  'dataservice_connector_options' => {
    'lonelycluster' => {}
  },
  'repl_services' => {
    'lonelycluster_qa_tx3_continuent_com' => {
      'deployment_host' => 'qa_tx3_continuent_com',
      'deployment_dataservice' => 'lonelycluster'
    },
    'lonelycluster_qa_tx2_continuent_com' => {
      'deployment_host' => 'qa_tx2_continuent_com',
      'deployment_dataservice' => 'lonelycluster'
    },
    'lonelycluster_qa_tx1_continuent_com' => {
      'deployment_host' => 'qa_tx1_continuent_com',
      'deployment_dataservice' => 'lonelycluster'
    }
  },
  'connectors' => {
    'qa_tx8_continuent_com' => {
      'deployment_host' => 'qa_tx8_continuent_com',
      'deployment_dataservice' => [
        'lonelycluster'
      ]
    },
    'qa_tx2_continuent_com' => {
      'deployment_host' => 'qa_tx2_continuent_com',
      'deployment_dataservice' => [
        'lonelycluster'
      ]
    }
  },
  'dataservices' => {
    'lonelycluster' => {
      'dataservice_master_host' => 'qa.tx1.continuent.com',
      'dataservice_hosts' => 'qa.tx1.continuent.com,qa.tx2.continuent.com,qa.tx3.continuent.com',
      'dataservice_connectors' => 'qa.tx2.continuent.com,qa.tx8.continuent.com',
      'dataservice_witnesses' => 'qa.tx8.continuent.com',
      'dataservice_name' => 'lonelycluster'
    }
  },
  'dataservice_replication_options' => {
    'lonelycluster' => {
      'repl_backup_directory' => '/var/continuent/backups',
      'repl_datasource_user' => 'tungsten',
      'repl_datasource_log_directory' => '/var/lib/mysql',
      'repl_backup_method' => 'xtrabackup',
      'repl_datasource_boot_script' => '/etc/init.d/mysql',
      'repl_datasource_mysql_conf' => '/etc/my.cnf',
      'repl_datasource_password' => 'secret',
      'repl_datasource_port' => '3306'
    }
  },
  'dataservice_host_options' => {
    'lonelycluster' => {
      'mysql_connectorj_path' => '/opt/continuent/mysql-connector-java-5.1.16-bin.jar',
      'start_and_report' => 'true',
      'user' => 'tungsten',
      'root_command_prefix' => 'true',
      'home_directory' => '/opt/continuent/cookbook_test'
    }
  },
  'dataservice_manager_options' => {
    'lonelycluster' => {
      'mgr_listen_interface' => 'eth1'
    }
  },
  'managers' => {
    'lonelycluster_qa_tx3_continuent_com' => {
      'deployment_host' => 'qa_tx3_continuent_com',
      'deployment_dataservice' => 'lonelycluster'
    },
    'lonelycluster_qa_tx2_continuent_com' => {
      'deployment_host' => 'qa_tx2_continuent_com',
      'deployment_dataservice' => 'lonelycluster'
    },
    'lonelycluster_qa_tx1_continuent_com' => {
      'deployment_host' => 'qa_tx1_continuent_com',
      'deployment_dataservice' => 'lonelycluster'
    }
  }
};
$tungsten = {
  'hosts' => {
    'qa_tx8_continuent_com' => {
      'host_name' => 'qa.tx8.continuent.com'
    }
  },
  'dataservice_connector_options' => {
    'lonelycluster' => {}
  },
  'repl_services' => {},
  'connectors' => {
    'qa_tx8_continuent_com' => {
      'deployment_host' => 'qa_tx8_continuent_com',
      'deployment_dataservice' => [
        'lonelycluster'
      ]
    }
  },
  'dataservices' => {
    'lonelycluster' => {
      'dataservice_master_host' => 'qa.tx1.continuent.com',
      'dataservice_hosts' => 'qa.tx1.continuent.com,qa.tx2.continuent.com,qa.tx3.continuent.com',
      'dataservice_connectors' => 'qa.tx2.continuent.com,qa.tx8.continuent.com',
      'dataservice_witnesses' => 'qa.tx8.continuent.com',
      'dataservice_name' => 'lonelycluster'
    }
  },
  'config_target_basename' => 'tungsten-enterprise-1.5.1-8_pid18459',
  'deployment_host' => 'qa_tx8_continuent_com',
  'dataservice_replication_options' => {
    'lonelycluster' => {
      'repl_backup_directory' => '/var/continuent/backups',
      'repl_datasource_user' => 'tungsten',
      'repl_datasource_boot_script' => '/etc/init.d/mysql',
      'repl_datasource_mysql_conf' => '/etc/my.cnf',
      'repl_datasource_password' => 'secret',
      'repl_datasource_log_directory' => '/var/lib/mysql',
      'repl_backup_method' => 'xtrabackup',
      'repl_datasource_port' => '3306'
    }
  },
  'dataservice_manager_options' => {
    'lonelycluster' => {
      'mgr_listen_interface' => 'eth1'
    }
  },
  '__system_defaults_will_be_overwritten__' => {
    'config_target_basename' => 'tungsten-enterprise-1.5.1-8_pid18459',
    'hosts' => {
      'qa_tx8_continuent_com' => {
        'target_basename' => 'tungsten-enterprise-1.5.1-8_pid18459',
        'target_directory' => '/opt/continuent/cookbook_test/releases/tungsten-enterprise-1.5.1-8_pid18459',
        'mysql_connectorj_path' => '/opt/continuent/mysql-connector-java-5.1.16-bin.jar',
        'releases_directory' => '/opt/continuent/cookbook_test/releases',
        'temp_directory' => '/tmp',
        'svc_path_connector' => '/opt/continuent/cookbook_test/tungsten/tungsten-connector/bin/connector',
        'profile_script' => '',
        'user' => 'tungsten',
        'home_directory' => '/opt/continuent/cookbook_test',
        'logs_directory' => '/opt/continuent/cookbook_test/service_logs',
        'install' => 'false',
        'host_enable_connector' => 'true',
        'config_directory' => '/opt/continuent/cookbook_test/conf',
        'deployment_dataservice' => 'lonelycluster',
        'config_filename' => '/opt/continuent/cookbook_test/conf/tungsten.cfg',
        'start_and_report' => 'true',
        'root_command_prefix' => 'true',
        'svc_path_replicator' => '/opt/continuent/cookbook_test/tungsten/tungsten-replicator/bin/replicator',
        'host_name' => 'qa_tx8_continuent_com',
        'host_enable_replicator' => 'false',
        'svc_path_manager' => '/opt/continuent/cookbook_test/tungsten/tungsten-manager/bin/manager',
        'start' => 'true',
        'current_release_directory' => '/opt/continuent/cookbook_test/tungsten'
      }
    },
    'deploy_current_package' => 'true',
    'repl_services' => {},
    'managers' => {},
    'connectors' => {
      'qa_tx8_continuent_com' => {
        'router_gateway_port' => '11999',
        'connector_db_version' => '5.5.25-log-tungsten',
        'connector_listen_port' => '9999',
        'connector_default_schema' => 'tungsten',
        'connector_password_lines' => '',
        'connector_keepalive_timeout' => '0',
        'connector_direct_lines' => '',
        'connector_rwsplitting' => 'false',
        'connector_relative_slave_status' => 'false',
        'connector_disconnect_timeout' => '5',
        'connector_ro_addresses' => '',
        'connector_delete_user_map' => 'false',
        'connector_rw_addresses' => '',
        'connector_delay_before_offline' => '600',
        'connector_autoreconnect' => 'true',
        'connector_smartscale' => 'false',
        'router_jmx_port' => '10999',
        'connector_db_protocol' => 'mysql',
        'connector_password' => 'secret',
        'connector_user' => 'tungsten'
      }
    },
    'dataservices' => {
      'lonelycluster' => {
        'dataservice_vip_enabled' => 'false',
        'dataservice_is_composite' => 'false',
        'dataservice_connectors' => '',
        'dataservice_relay_enabled' => 'false',
        'dataservice_thl_port' => '2112',
        'dataservice_name' => 'default'
      }
    }
  },
  'dataservice_host_options' => {
    'lonelycluster' => {
      'mysql_connectorj_path' => '/opt/continuent/mysql-connector-java-5.1.16-bin.jar',
      'start_and_report' => 'true',
      'user' => 'tungsten',
      'root_command_prefix' => 'true',
      'home_directory' => '/opt/continuent/cookbook_test'
    }
  },
  'managers' => {}
};
