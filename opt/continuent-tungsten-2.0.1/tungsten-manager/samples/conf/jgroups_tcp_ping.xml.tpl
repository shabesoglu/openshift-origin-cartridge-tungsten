
	<!--
		JGroups Protocol Stack Configuration. Based on TCP and SEQUENCER, but
		without multicast - instead TCPPING with a static list of members is
		used for discovery. IMPORTANT: you must define members in
		TCPPING.initial_hosts HOST1 and HOST2 are dummy names. Exchange them
		for real hostnames or IP addresses. Add more hosts if your group is
		larger than two members. Firewall configuration note: By default,
		jgroups will use tcp port 7800. If not available, it will try the next
		ports incrementally. You can reduce or change the port range in the
		TCP config below with: start_port="7800" end_port="7800"
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
		oob_thread_pool.rejection_policy="Run" start_port="@{MGR_GROUP_COMMUNICATION_PORT}" end_port="@{MGR_GROUP_COMMUNICATION_PORT}" />
	<TCPPING initial_hosts="@{MGR_GROUP_COMMUNICATION_INITIAL_HOSTS}" port_range="0"
		timeout="3000" num_initial_members="@{MGR_GROUP_COMMUNICATION_NUM_INITIAL_HOSTS}" />
	<MERGE2 max_interval="10000"
    min_interval="5000"/>
	<FD_SOCK />
	<FD timeout="5000" max_tries="2" shun="false" />
	<VERIFY_SUSPECT timeout="5000" num_msgs="2" />
	<pbcast.NAKACK use_mcast_xmit="false" gc_lag="0"
		retransmit_timeout="50,75,100,300,600,2400,4800"
		discard_delivered_msgs="true" />
	<pbcast.STABLE stability_delay="500" desired_avg_gossip="1000"
		max_bytes="0" />
	<pbcast.GMS print_local_addr="true" join_timeout="20000"
		shun="false" />
</config>