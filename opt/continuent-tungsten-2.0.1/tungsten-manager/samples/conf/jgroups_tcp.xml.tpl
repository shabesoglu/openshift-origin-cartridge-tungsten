
	<!--
		JGroups Protocol Stack Configuration for sites that support multicast.

		Firewall configuration note: By default, JGroups will use TCP port
		7800. If not available, it will try the next ports incrementally. You
		can reduce or change the port range in the TCP config below with:

		start_port="7800" end_port="7800"
	-->

<config>
	<TCP bind_addr="@{MGR_LISTEN_ADDRESS}" loopback="false" discard_incompatible_packets="true"
		use_incoming_packet_handler="true" enable_bundling="false"
		enable_diagnostics="true" thread_naming_pattern="cl"

		use_concurrent_stack="false" thread_pool.enabled="false"
		thread_pool.min_threads="8" thread_pool.max_threads="40"
		thread_pool.keep_alive_time="5000" thread_pool.queue_enabled="false"
		thread_pool.queue_max_size="100" thread_pool.rejection_policy="Run"

		oob_thread_pool.enabled="false" oob_thread_pool.min_threads="8"
		oob_thread_pool.max_threads="20" oob_thread_pool.keep_alive_time="5000"
		oob_thread_pool.queue_enabled="false" oob_thread_pool.queue_max_size="100"
		oob_thread_pool.rejection_policy="Run" start_port="@{MGR_PROTOCOL_START_PORT}" end_port="@{MGR_PROTOCOL_END_PORT}" />
	<MPING timeout="2000" receive_on_all_interfaces="true"
		mcast_addr="228.10.10.10" mcast_port="45566" num_initial_members="@{MGR_PROTOCOL_NUM_INITIAL_HOSTS}" />
	<MERGE2 max_interval="40000"
    min_interval="20000"/>
	<FD_SOCK />
	<FD timeout="3000" max_tries="5" shun="false" />
	<VERIFY_SUSPECT timeout="3000" num_msgs="5" />
	<pbcast.NAKACK use_mcast_xmit="false" gc_lag="0"
		retransmit_timeout="50,75,100,300,600,2400,4800"
		discard_delivered_msgs="true" />
	<pbcast.STABLE stability_delay="500" desired_avg_gossip="1000"
		max_bytes="0" />
	<!--<VIEW_SYNC avg_send_interval="60000" />-->
	<pbcast.GMS print_local_addr="true" join_timeout="20000"
		shun="false" />
</config>
