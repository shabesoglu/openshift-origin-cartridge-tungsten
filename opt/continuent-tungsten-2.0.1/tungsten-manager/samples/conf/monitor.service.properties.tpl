# monitor.properties
name=monitor
command.start=${cluster.home}/../tungsten-monitor/bin/monitor start
command.stop=${cluster.home}/../tungsten-monitor/bin/monitor stop
command.restart=${cluster.home}/../tungsten-monitor/bin/monitor restart
command.status=${cluster.home}/../tungsten-monitor/bin/monitor status
command.tail=tail -n 100 ${cluster.home}/../tungsten-monitor/log/monitor.log
