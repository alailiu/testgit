
*** Settings ***
Library    jnpr/toby/engines/config/config.py
Library    XML
Resource   jnpr/toby/Master.robot


*** Keywords ***
Cleanup the configurations from devices in Topology
    [Documentation]  Cleanup all the nodes configuaration in the topology
    [Arguments]   @{device_list}

    #Clear all the configurations on the nodes
    :FOR   ${device}    IN     @{device_list}
    \      @{cmd_list}     create list
    \      ...             set system services telnet
    \      ...             delete chassis
    \      ...             delete security
    \      ...             delete interfaces
    \      ...             delete routing-instances
    \      ...             delete routing-options
    \      ...             delete forwarding-options
    \      ...             delete protocols
    \      ...             delete vlans
    \      ...             delete access
    \      ...             delete services
    \      ...             delete firewall
    \      ...             delete system services dhcp-local-server
    \      ...             delete system processes dhcp-service
    \      ...             delete groups global interfaces lo0
    \      ...             set system services ftp
    \      ...             set system services ssh
    \      Config Engine   device_list=${device}  cmd_list=@{cmd_list}   commit=true   commit_timeout=${120}

Change the mgt inface of security zone for Flow Mode
    [Documentation]  Change the mgt interface to the groups global security zone
    [Arguments]  @{device_list}

    :FOR   ${device}    IN     @{device_list}
    \      @{cmd_list}     create list
    \      ...             delete groups global security zones security-zone HOST interfaces
    \      ...             set groups global security zones security-zone HOST interfaces ${t['resources']['${device}']['system']['primary']['controllers']['re0']['mgt-intf-name']}
    \      Config Engine   device_list=${device}  cmd_list=@{cmd_list}   commit=true   commit_timeout=${120}

Cleanup the twamp client sessions and configurations
    [Documentation]   Cleanup the twamp sessions and configurations between testcases
    #Stop the twamp client session
    Stop twamp client connction     ${client}

    #Clear the twamp client and server configurations
    @{client_list}     create list
    ...                delete services rpm twamp client
    ...                commit

    @{server_list}     create list
    ...                delete services rpm twamp server
    ...                commit

    execute config command on device      device=${client}   command_list=@{client_list}
    execute config command on device      device=${server}   command_list=@{server_list}

Cleanup toby configuration files on device
    [Documentation]  Cleanup all the configuration files which generated in the toby scripts
    [Arguments]   @{dh_list}
    #Clear all the configuration files generate from toby scripts on the three nodes
    :FOR   ${dh}    IN     @{dh_list}
    \       Execute Shell Command On Device     device=${dh}    command=rm /tmp/toby_script_*.conf    timeout=${120}


Switch the devices to the Packet mode from Flow mode
    [Documentation]  Switch the devices to the Packet Mode
    [Arguments]   ${device}


    @{cmd_list}     create list
    ...             delete groups global security
    ...             set security forwarding-options family mpls mode packet-based
    ...             commit

    execute config command on device      device=${device}   command_list=@{cmd_list}
    sleep    5s
    reboot device      device=${device}
    sleep  30s
    ${mode}    Get the mode from devices     ${device}
    should be true    ${mode}=='packet based'

Switch the devices to the Flow mode from Packet mode
    [Documentation]  Switch the devices to the Flow mode from Packet mode
    [Arguments]  ${device}

    @{cmd_list}     create list
    ...             delete security forwarding-options family mpls mode packet-based
    ...             set groups global security policies default-policy permit-all
    ...             set groups global security zones security-zone HOST host-inbound-traffic system-services any-service
    ...             set groups global security zones security-zone HOST host-inbound-traffic protocols all
    ...             set groups global security zones security-zone HOST interfaces ge-0/0/0.0
    ...             commit

    execute config command on device      device=${device}   command_list=@{cmd_list}
    sleep    5s
    reboot device      device=${device}
    sleep   20s
    ${mode}    Get the mode from devices     ${device}
    should be true    ${mode}=='flow based'

Get the mode from devices
     [Documentation]  Get the mode from devices
     [Arguments]   ${device}

     ${response}   execute cli command on device     device=${device}   command=show security flow status | display xml
     ${mode}    get element text     ${response}       .//flow-forwarding-mode-inet
     [return]    ${mode}

Check all the devices on Flow Mode
     [Documentation]  Check and make sure all the devices on Flow mode

     sleep  20s
     :FOR   ${device}     IN   @{dh_list}
     \      ${mode}   get the mode from devices    ${device}
     \      run keyword if    '${mode}'=='packet based'     Log to Console    The node ${device} is not in Flow Mode,Please manually configured it to Flow Mode!!

Check all the devices on Packet Mode
     [Documentation]  Check and make sure all the devices on Packet mode

     sleep   20s
     :FOR   ${device}     IN   @{dh_list}
     \      ${mode}   get the mode from devices    ${device}
     \      run keyword if    '${mode}'=='flow based'     Log to console   The node ${device} is not in Packet Mode,Please manually configured it to Packet Mode!!


Collect the basic data from devices
    [Documentation]  Collect the basic data from the test devices
    [Arguments]  @{dh_list}
    @{cli_cmd}      create list
     ...             run show version
     ...             run show interfaces terse
     ...             run show system license

     :FOR    ${dh}    IN     @{dh_list}
      \       execute config command on device      device=${dh}   command_list=@{cli_cmd}

Initialize the test environment of Topology with two nodes
    [Documentation]   Initialize the test environment of Topology with two nodes

    Toby Suite Setup
    @{device_list}   create list    r0    r1
    ${r0}    Get handle    resource=r0
    ${r1}    Get Handle    resource=r1
    @{dh_list}   create list    ${r0}    ${r1}
    set suite variable      @{dh_list}
    set suite variable      @{device_list}
    set suite variable      ${r0}
    set suite variable      ${r1}
    set suite variable      ${client}      ${r0}
    set suite variable      ${server}      ${r1}
    set suite variable      ${client_node}     r0
    set suite variable      ${server_node}     r1
    set suite variable      ${target_addr}     ${tv['uv-r1_r0-ip']}
    set suite variable      ${client_ip}     ${tv['uv-r0_r1-ip']}
    Collect the basic data from devices    @{dh_list}
    Cleanup the configurations from devices in Topology    @{device_list}

Initialize the test environment of HA
    [Documentation]  Initialize the test enviroment of HA

    Toby Suite Setup
    @{device_list}   create list    r0    r1
    ${r0}    Get handle    resource=r0
    ${r1}    Get Handle    resource=r1
    @{dh_list}   create list    ${r0}    ${r1}
    set suite variable      @{dh_list}
    set suite variable      @{device_list}
    set suite variable      ${server_interface}    reth0
    set suite variable      ${r0}
    set suite variable      ${r1}
    set suite variable      ${client}      ${r0}
    set suite variable      ${server}      ${r1}
    set suite variable      ${client_node}     r0
    set suite variable      ${server_node}     r1
    set suite variable      ${target_addr}     ${tv['uv-r0_r1-ip']}
    set suite variable      ${client_ip}     ${tv['uv-r1_r0-ip']}
    Collect the basic data from devices    @{dh_list}

    @{cmd_lst_r1}    create list
    ...             set system services telnet
    ...             delete security
    ...             delete interfaces
    ...             delete routing-instances
    ...             delete routing-options
    ...             delete forwarding-options
    ...             delete protocols
    ...             delete vlans
    ...             delete access
    ...             delete services
    ...             delete firewall
    ...             delete system services dhcp-local-server
    ...             delete system processes dhcp-service
    ...             delete groups global interfaces lo0
    ...             set system services ftp
    ...             set system services ssh
    ...             commit

    execute config command on device      device=${r1}   command_list=@{cmd_lst_r1}   timeout=${150}

    @{cmd_lst_r0}    create list
    ...             delete groups global security zones security-zone HOST interfaces
    ...             set groups global security zones security-zone HOST interfaces ${t['resources']['r0']['system']['primary']['controllers']['re0']['mgt-intf-name']}
    ...             set system services telnet
    ...             delete security
    ...             delete interfaces
    ...             delete routing-instances
    ...             delete routing-options
    ...             delete forwarding-options
    ...             delete protocols
    ...             delete vlans
    ...             delete access
    ...             delete services
    ...             delete firewall
    ...             delete system services dhcp-local-server
    ...             delete system processes dhcp-service
    ...             delete groups global interfaces lo0
    ...             set system services ftp
    ...             set system services ssh
    ...             commit

    execute config command on device      device=${r0}   command_list=@{cmd_lst_r0}   timeout=${150}

Initialize the test environment of Topology with three nodes
    [Documentation]   Initialize the test environment of Topology consist of three nodes

    Toby Suite Setup
    @{device_list}   create list    r0    r1   r2
    ${r0}    Get handle    resource=r0
    ${r1}    Get Handle    resource=r1
    ${r2}    Get Handle    resource=r2
    @{dh_list}   create list    ${r0}    ${r1}    ${r2}
    set suite variable      @{dh_list}
    set suite variable      @{device_list}
    set suite variable      ${r0}
    set suite variable      ${r1}
    set suite variable      ${r2}
    set suite variable      ${client}      ${r0}
    set suite variable      ${trasit}      ${r1}
    set suite variable      ${server}      ${r2}
    set suite variable      ${client_node}     r0
    set suite variable      ${transit_node}    r1
    set suite variable      ${server_node}     r2
    set suite variable      ${target_addr}     ${tv['uv-r2_r1-ip']}
    set suite variable      ${client_ip}    ${tv['uv-r0_r1-ip']}
    Collect the basic data from devices    @{dh_list}
    Change the mgt inface of security zone for Flow Mode    @{device_list}
    Cleanup the configurations from devices in Topology     @{device_list}

Initialize the test environment of Topology with three nodes for Packet Mode
    [Documentation]   Initialize the test environment of Topology consist of three nodes

    Toby Suite Setup
    @{device_list}   create list    r0    r1   r2
    ${r0}    Get handle    resource=r0
    ${r1}    Get Handle    resource=r1
    ${r2}    Get Handle    resource=r2
    @{dh_list}   create list    ${r0}    ${r1}    ${r2}
    set suite variable      @{dh_list}
    set suite variable      @{device_list}
    set suite variable      ${r0}
    set suite variable      ${r1}
    set suite variable      ${r2}
    set suite variable      ${client}      ${r0}
    set suite variable      ${trasit}      ${r1}
    set suite variable      ${server}      ${r2}
    set suite variable      ${client_node}     r0
    set suite variable      ${transit_node}    r1
    set suite variable      ${server_node}     r2
    set suite variable      ${target_addr}     ${tv['uv-r2_r1-ip']}
    set suite variable      ${client_ip}    ${tv['uv-r0_r1-ip']}
    Collect the basic data from devices    @{dh_list}
    Cleanup the configurations from devices in Topology     @{device_list}

Init the Configurations on two nodes in Flow Mode
    [Documentation]   Init configurations on two devices which in flow mode
    #Init the configuration on the devices
    @{cmd_list_r0}     create list
    ...                set interfaces ${tv['r0__r0r1__pic']} unit 0 family inet address ${tv['uv-r0_r1-ip']}/${tv['uv-mask']}
    ...                set interfaces ${tv['r0__r0r1__pic']} unit 0 family inet6 address ${tv['uv-r0_r1-ip6']}/${tv['uv-mask6']}
    ...                set security zones security-zone trust host-inbound-traffic system-services all
    ...                set security zones security-zone trust host-inbound-traffic protocols all
    ...                set security policies default-policy permit-all
    ...                set security zones security-zone trust interfaces ${tv['r0__r0r1__pic']}
    ...                commit
    execute config command on device      device=${r0}   command_list=@{cmd_list_r0}

    @{cmd_list_r1}     create list
    ...                set interfaces ${tv['r1__r1r0__pic']} unit 0 family inet address ${tv['uv-r1_r0-ip']}/${tv['uv-mask']}
    ...                set interfaces ${tv['r1__r1r0__pic']} unit 0 family inet6 address ${tv['uv-r1_r0-ip6']}/${tv['uv-mask6']}
    ...                set security zones security-zone trust host-inbound-traffic system-services all
    ...                set security zones security-zone trust host-inbound-traffic protocols all
    ...                set security policies default-policy permit-all
    ...                set security zones security-zone trust interfaces ${tv['r1__r1r0__pic']}
    ...                commit
    execute config command on device      device=${r1}   command_list=@{cmd_list_r1}

    sleep   20s
    ${response1}   execute cli command on device    device=${client}   command=ping ${target_addr} count 10
    should not contain     ${response1}     100% packet loss
    ${response2}   execute cli command on device    device=${server}   command=ping ${client_ip} count 10
    should not contain     ${response2}     100% packet loss


Init the Configurations on three nodes in Flow Mode
    [Documentation]  Init the Configurations on three nodes in Flow Mode
    @{cmd_list_r0}     create list
    ...                set interfaces ${tv['r0__r0r1__pic']} unit 0 family inet address ${tv['uv-r0_r1-ip']}/${tv['uv-mask']}
    ...                set security zones security-zone trust host-inbound-traffic system-services all
    ...                set security zones security-zone trust host-inbound-traffic protocols all
    ...                set security policies default-policy permit-all
    ...                set security zones security-zone trust interfaces ${tv['r0__r0r1__pic']}
    ...                set routing-options static route ${tv['uv-r2_r1-ip']} next-hop ${tv['uv-r1_r0-ip']}
    ...                commit
    execute config command on device      device=${r0}   command_list=@{cmd_list_r0}

    @{cmd_list_r1}     create list
    ...                set interfaces ${tv['r1__r1r0__pic']} unit 0 family inet address ${tv['uv-r1_r0-ip']}/${tv['uv-mask']}
    ...                set interfaces ${tv['r1__r1r2__pic']} unit 0 family inet address ${tv['uv-r1_r2-ip']}/${tv['uv-mask']}
    ...                set security zones security-zone trust host-inbound-traffic system-services all
    ...                set security zones security-zone trust host-inbound-traffic protocols all
    ...                set security policies default-policy permit-all
    ...                set security zones security-zone trust interfaces ${tv['r1__r1r0__pic']}
    ...                set security zones security-zone trust interfaces ${tv['r1__r1r2__pic']}
    ...                commit
    execute config command on device      device=${r1}   command_list=@{cmd_list_r1}

    @{cmd_list_r2}     create list
    ...                set interfaces ${tv['r2__r2r1__pic']} unit 0 family inet address ${tv['uv-r2_r1-ip']}/${tv['uv-mask']}
    ...                set security zones security-zone trust host-inbound-traffic system-services all
    ...                set security zones security-zone trust host-inbound-traffic protocols all
    ...                set security policies default-policy permit-all
    ...                set security zones security-zone trust interfaces ${tv['r2__r1r1__pic']}
    ...                set routing-options static route ${tv['uv-r0_r1-ip']} next-hop ${tv['uv-r1_r2-ip']}
    ...                commit
    execute config command on device      device=${r2}   command_list=@{cmd_list_r2}

    sleep   20s
    ${response1}   execute cli command on device    device=${client}   command=ping ${target_addr} count 10
     should not contain     ${response1}     100% packet loss
     ${response2}   execute cli command on device    device=${server}   command=ping ${client_ip} count 10
     should not contain     ${response2}     100% packet loss


Init the Configurations on three nodes in Packet Mode
    [Documentation]  Init Configrations on three nodes with Packet Mode
    #Init the configuration on the devices
    @{cmd_list_r0}     create list
    ...                set interfaces ${tv['r0__r0r1__pic']} unit 0 family inet address ${tv['uv-r0_r1-ip']}/${tv['uv-mask']}
    ...                set routing-options static route ${tv['uv-r2_r1-ip']} next-hop ${tv['uv-r1_r0-ip']}
    ...                commit
    execute config command on device      device=${r0}   command_list=@{cmd_list_r0}

    @{cmd_list_r1}     create list
    ...                set interfaces ${tv['r1__r1r0__pic']} unit 0 family inet address ${tv['uv-r1_r0-ip']}/${tv['uv-mask']}
    ...                set interfaces ${tv['r1__r1r2__pic']} unit 0 family inet address ${tv['uv-r1_r2-ip']}/${tv['uv-mask']}
    ...                commit
    execute config command on device      device=${r1}   command_list=@{cmd_list_r1}

    @{cmd_list_r2}     create list
    ...                set interfaces ${tv['r2__r2r1__pic']} unit 0 family inet address ${tv['uv-r2_r1-ip']}/${tv['uv-mask']}
    ...                set routing-options static route ${tv['uv-r0_r1-ip']} next-hop ${tv['uv-r1_r2-ip']}
    ...                commit
    execute config command on device      device=${r2}   command_list=@{cmd_list_r2}

     sleep  20s
     ${response1}   execute cli command on device    device=${client}   command=ping ${target_addr} count 10
     should not contain     ${response1}     100% packet loss
     ${response2}   execute cli command on device    device=${server}   command=ping ${client_ip} count 10
     should not contain     ${response2}     100% packet loss

Init the configurations of HA topology
    [Documentation]  Init the configuraitons of HA topo

    @{cmd_list_r1}     create list
    ...                set chassis cluster reth-count 4
    ...                set chassis cluster redundancy-group 0 node 0 priority 100
    ...                set chassis cluster redundancy-group 0 node 1 priority 1
    ...                set chassis cluster redundancy-group 1 node 0 priority 100
    ...                set chassis cluster redundancy-group 1 node 1 priority 1
    ...                set interfaces ${tv['r1__r1r0_1__pic']} gigether-options redundant-parent reth0
    ...                set interfaces ${tv['r1__r1r0_2__pic']} gigether-options redundant-parent reth0
    ...                set interfaces reth0 redundant-ether-options redundancy-group 1
    ...                set chassis cluster redundancy-group 1 interface-monitor reth0
    ...                set interfaces reth0 unit 0 family inet address ${tv['uv-r1_r0-ip']}/${tv['uv-mask']}
    ...                set security zones security-zone trust host-inbound-traffic system-services all
    ...                set security zones security-zone trust host-inbound-traffic protocols all
    ...                set security policies default-policy permit-all
    ...                set security zones security-zone trust interfaces reth0
    ...                set chassis cluster redundancy-group 1 interface-monitor reth0 weight 255
    ...                commit
    execute config command on device      device=${r1}   command_list=@{cmd_list_r1}   timeout=${150}

    @{cmd_list_r0}     create list
    ...                set interfaces ${tv['r0__r0r1__pic']} unit 0 family inet address ${tv['uv-r0_r1-ip']}/${tv['uv-mask']}
    ...                set security zones security-zone trust host-inbound-traffic system-services all
    ...                set security zones security-zone trust host-inbound-traffic protocols all
    ...                set security policies default-policy permit-all
    ...                set security zones security-zone trust interfaces ${tv['r0__r0r1__pic']}
    ...                commit
    execute config command on device      device=${r0}   command_list=@{cmd_list_r0}

    sleep   20s
    ${response1}   execute cli command on device    device=${r0}   command=ping ${tv['uv-r1_r0-ip']} count 10
    should not contain     ${response1}     100% packet loss
    ${response2}   execute cli command on device    device=${r1}   command=ping ${tv['uv-r0_r1-ip']} count 10
    should not contain     ${response2}     100% packet loss


Initialize the test environment of Topology with LAG
    [Documentation]   Initialize the test environment of Topology with LAG

    Toby Suite Setup
    @{device_list}   create list    r0    r1
    ${r0}    Get handle    resource=r0
    ${r1}    Get Handle    resource=r1
    @{dh_list}   create list    ${r0}    ${r1}
    ${client_interface}   Set Variable      ae0
    ${server_interface}   Set Variable      ae0
    set suite variable      @{dh_list}
    set suite variable      @{device_list}
    set suite variable      ${r0}
    set suite variable      ${r1}
    set suite variable      ${client}      ${r0}
    set suite variable      ${server}      ${r1}
    set suite variable      ${target_addr}     ${tv['uv-r1_r0-ip']}
    set suite variable      ${client_ip}     ${tv['uv-r0_r1-ip']}
    set suite variable      ${client_interface}
    set suite variable      ${server_interface}
    Collect the basic data from devices    @{dh_list}
    Cleanup the configurations from devices in Topology    @{device_list}

Init the configurations of LAG topology
    [Documentation]  Init the configuraitons of LAG topo

    @{cmd_list_r0}     create list
    ...                set chassis aggregated-devices ethernet device-count 4
    ...                set interfaces ${tv['r0__r0r1_1__pic']} gigether-options 802.3ad ae0
    ...                set interfaces ${tv['r0__r0r1_2__pic']} gigether-options 802.3ad ae0
    ...                set interfaces ae0 unit 0 family inet address ${tv['uv-r0_r1-ip']}/${tv['uv-mask']}
    ...                set security zones security-zone trust host-inbound-traffic system-services all
    ...                set security zones security-zone trust host-inbound-traffic protocols all
    ...                set security policies default-policy permit-all
    ...                set security zones security-zone trust interfaces ae0
    ...                set interfaces ae0 aggregated-ether-options lacp active
    ...                commit
    execute config command on device      device=${r0}   command_list=@{cmd_list_r0}   timeout=${150}

    @{cmd_list_r1}     create list
    ...                set chassis aggregated-devices ethernet device-count 4
    ...                set interfaces ${tv['r1__r1r0_1__pic']} gigether-options 802.3ad ae0
    ...                set interfaces ${tv['r1__r1r0_2__pic']} gigether-options 802.3ad ae0
    ...                set interfaces ae0 unit 0 family inet address ${tv['uv-r1_r0-ip']}/${tv['uv-mask']}
    ...                set security zones security-zone trust host-inbound-traffic system-services all
    ...                set security zones security-zone trust host-inbound-traffic protocols all
    ...                set security policies default-policy permit-all
    ...                set security zones security-zone trust interfaces ae0
    ...                set interfaces ae0 aggregated-ether-options lacp active
    ...                commit
    execute config command on device      device=${r1}   command_list=@{cmd_list_r1}  timeout=${150}

    sleep   20s
    ${response1}   execute cli command on device    device=${r0}   command=ping ${tv['uv-r1_r0-ip']} count 10
    should not contain     ${response1}     100% packet loss
    ${response2}   execute cli command on device    device=${r1}   command=ping ${tv['uv-r0_r1-ip']} count 10

Failover the Reduandancy Group 0
    [Documentation]  Failover the redundancy group 0

    ${num}   Get the secondary node info of RG0
    ${response}   execute cli command on device    device=${r1}   command=request chassis cluster failover redundancy-group 0 node ${num}
    ${status}   run keyword and return status   should contain   ${response}     Please reset it before requesting a failover
    run keyword if   '${status}' == 'True'    Reset the redundancy group    node_num=${num}
    sleep  30s

Reset the redundancy group
    [Documentation]  Reset redundancy group 0
    [Arguments]   ${node_num}

    execute cli command on device    device=${r1}   command=request chassis cluster failover reset redundancy-group 0
    sleep  20s
    execute cli command on device    device=${r1}   command=request chassis cluster failover redundancy-group 0 node ${node_num}

Set the primary node to handle
    [Documentation]  Set the primary node to handle

    sleep   150s
    ${num}    Get the primary node info of RG0
    run keyword if   ${num} == 0    Set Current System Node    device=${r1}   system_node=primary
    run keyword if   ${num} == 1   Set Current System Node    device=${r1}   system_node=slave
    sleep   10s

Get the primary node info of RG0
    [Documentation]  Get the primary node info of RG0

   # set test variable    ${pri_num}   none
    ${response}    execute cli command on device    device=${r1}   command=show chassis cluster status |display xml
    ${status1}   get element text   ${response}     chassis-cluster-status/redundancy-group[1]/device-stats/redundancy-group-status[1]
    ${status2}   get element text   ${response}     chassis-cluster-status/redundancy-group[1]/device-stats/redundancy-group-status[2]
    run keyword if   '${status1}'=='primary'    set test variable   ${pri_num}  0
    run keyword if   '${status2}'=='primary'    set test variable   ${pri_num}  1
    [Return]  ${pri_num}

Faiover the Reduandancy Group 1
    [Documentation]  Failover the redundancy group 1

    execute cli command on device    device=${r1}   command=request chassis cluster failover redundancy-group 1 node 0
    sleep  60s
    execute cli command on device    device=${r1}   command=request chassis cluster failover redundancy-group 1 node 1
    sleep  60s

Restart the HA node
    [Documentation]  Restart the HA node

     reboot device      device=${r1}     timeout=${480}
     sleep  40s

Get the secondary node info of RG0
    [Documentation]  Get the secondary node info of RG0

   # set test variable  ${node_num}  none
    ${response}    execute cli command on device    device=${r1}   command=show chassis cluster status |display xml
    ${status1}   get element text   ${response}     chassis-cluster-status/redundancy-group[1]/device-stats/redundancy-group-status[1]
    ${status2}   get element text   ${response}     chassis-cluster-status/redundancy-group[1]/device-stats/redundancy-group-status[2]
    run keyword if   '${status1}'=='secondary'     set test variable  ${node_num}   0
    run keyword if    '${status2}'=='secondary'    set test variable  ${node_num}   1
    [Return]  ${node_num}

Config the twamp client with basic config
    [Documentation]  Config the twamp client with default config
    [Arguments]   ${connection_name}   ${session_name}  ${target_addr}  ${probe_count}

    @{cmd_list}     create list
    ...             set services rpm twamp client control-connection ${connection_name} authentication-mode none
    ...             set services rpm twamp client control-connection ${connection_name} target-address ${target_addr}
    ...             set services rpm twamp client control-connection ${connection_name} test-session ${session_name} target-address ${target_addr}
    ...             set services rpm twamp client control-connection ${connection_name} test-session ${session_name} probe-count ${probe_count}
    ...             commit

    execute config command on device      device=${client}   command_list=@{cmd_list}

Config the twamp server with basic config
    [Documentation]  Config the twamp server with default config
    [Arguments]  ${client_network}

    @{cmd_list}      create list
    ...              set services rpm twamp server authentication-mode none
    ...              set services rpm twamp server client-list client1 address ${client_network}
    ...              commit

     execute config command on device      device=${server}   command_list=@{cmd_list}   timeout=${150}
     sleep  20s

Prepare test file on local and remote
    [Documentation]  Config the twamp server with default config
     execute shell command on device      device=${client}   command=rm -rf /var/tmp/testfilelocal
     sleep  5s
     Save Device Configuration      device=${client}   file=/var/tmp/testfilelocal
     sleep  5s
     execute shell command on device      device=${server}   command=rm -rf /var/tmp/testfileremote
     sleep  5s
     Save Device Configuration      device=${server}   file=/var/tmp/testfileremote
     sleep  5s

     ${response}    execute shell command on device      device=${client}   command=ls -al testfilelocal
     ${filelocalsize} =   Should Match Regexp    ${response}    \\S+\\s+\\S+\\s+\\S+\\s+\\S+\\s+(\\d+)\\s+/
     Log to Console    "hbhbhb\n\n\n${filelocalsize}\n\n\nhbhbhb"

Scp file from local to remote
    [Documentation]  Config the twamp server with default config
    [Arguments]  ${server_ip}


    ${response}    execute cli command on device      device=${client}   command=scp /var/tmp/testfilelocal root@${server_ip}:/var/tmp/.   pattern=(no|word)
    ${status}   run keyword and return status   should contain   ${response}     Pass
    run keyword if   '${status}' == 'True'    execute cli command on device      device=${client}   command=Embe1mpls
    run keyword if   '${status}' == 'False'    execute cli command on device      device=${client}   command=yes   pattern=(word)

    execute cli command on device      device=${client}   command=Embe1mpls
    sleep  20s

Scp file from remote to local
    [Documentation]  Config the twamp server with default config
    [Arguments]  ${server_ip}


    execute cli command on device      device=${client}   command=scp root@${server_ip}:/var/tmp/testfileremote /var/tmp/.   pattern=(no|word)
    ${status}   run keyword and return status   should contain   ${response}     Pass
    run keyword if   '${status}' == 'True'    execute cli command on device      device=${client}   command=Embe1mpls
    run keyword if   '${status}' == 'False'    execute cli command on device      device=${client}   command=yes
    sleep  20s


Delete test files
    [Documentation]  Config the twamp server with default config

     execute shell command on device      device=${client}   command=rm -rf /var/tmp/testfileremote
     sleep  5s
     execute shell command on device      device=${server}   command=rm -rf /var/tmp/testfilelocal
     sleep  5s

Delete the Twamp Configuration
    [Documentation]  Delete the Twamp Configuration

    @{cmd_list}      create list
    ...              delete services rpm
    ...              commit

    execute config command on device      device=${client}   command_list=@{cmd_list}
    sleep  20s
    execute config command on device      device=${server}   command_list=@{cmd_list}
    sleep  20s

Delete the Twamp Configuration on middle node
    [Documentation]  Delete the Twamp Configuration on middle node

    @{cmd_list}      create list
    ...              delete services rpm
    ...              commit

    execute config command on device      device=${r1}   command_list=@{cmd_list}
    sleep  20s

Start twamp client connction
     [Documentation]  Start twamp client connction

     execute cli command on device    device=${client}   command=request services rpm twamp start client
     sleep   5s

Start twamp client2 connction
     [Documentation]  Start twamp client2 connction

     execute cli command on device    device=${r2}   command=request services rpm twamp start client
     sleep   5s

Stop twamp client connction
     [Documentation]  Stop twamp client connction

     execute cli command on device    device=${client}   command=request services rpm twamp stop client
     sleep   5s

Stop twamp client2 connction
     [Documentation]  Stop twamp client2 connction

     execute cli command on device    device=${r2}   command=request services rpm twamp stop client

Verify Twamp Server Control Connection
     [Documentation]  Check the Twamp Server Control Connection
     [Arguments]  ${client_addr}  ${port_range}  ${server_addr}  ${server_port}  ${session_cnt}

     ${args}    evaluate     {'args':[{'client_addr':'${client_addr}'},{'port_range':'${port_range}'},{'server_addr':'${server_addr}'},{'server_port':'${server_port}'},{'session_cnt':'${session_cnt}'}]}
     Verify checks     checks=twamp_server_connection_basic_check    devices=${server_node}    args=${args}


Verify Twamp Server Test Session
     [Documentation]  Check the Twamp Server Test Session
     [Arguments]  ${sender_addr}  ${port_range}  ${reflector_addr}

     ${args}    evaluate     {'args':[{'sender_addr':'${sender_addr}'},{'port_range':'${port_range}'},{'reflector_addr':'${reflector_addr}'}]}
     Verify checks     checks=twamp_server_session_basic_check    devices=${server_node}    args=${args}

Verify Twamp Client Control Connection
     [Documentation]  Check the Twamp Client Control Connection
     [Arguments]  ${connection_name}   ${client_addr}   ${server_addr}   ${server_port}

     ${args}    evaluate     {'args':[{'connection_name':'${connection_name}'},{'client_addr':'${client_addr}'},{'server_addr':'${server_addr}'},{'server_port':'${server_port}'}]}
     Verify checks     checks=twamp_client_connection_basic_check    devices=r0    args=${args}


Verify Twamp Client Test Probes Basic Info
     [Documentation]  Check the Twamp Client Probes Basic Info of Test Session
     [Arguments]   ${owner}  ${test_name}  ${srv_addr}   ${srv_port}   ${client_addr}  ${reflct_addr}  ${sender_addr}  ${test_size}

     ${args}    evaluate     {'args':[{'owner':'${owner}'},{'test_name':'${test_name}'},{'srv_addr':'${srv_addr}'},{'srv_port':'${srv_port}'},{'client_addr':'${client_addr}'},{'reflct_addr':'${reflct_addr}'},{'sender_addr':'${sender_addr}'},{'test_size':'${test_size}'}]}
     Verify checks     checks=twamp_client_probes_result_basic_info_check    devices=r0   args=${args}


Verify Twamp Client Test Probes Single Results
     [Documentation]  Check the Twamp Client Test Probes Single Result
     [Arguments]  ${rtt_range}

     ${args}    evaluate     {'args':[{'rtt_range':'${rtt_range}'}]}
     Verify checks     checks=twamp_client_probes_single_results_check    devices=r0    args=${args}

Verify Twamp Client Test Probes Current Results
     [Documentation]  Check the Twamp Client Test Probes Current Results
     [Arguments]   ${test_size}  ${rtt_range}

     ${args}    evaluate     {'args':[{'test_size':'${test_size}'},{'rtt_range':'${rtt_range}'}]}
     Verify checks     checks=twamp_client_probes_current_results_check    devices=r0    args=${args}

Verify Twamp Client Test Probes One Sample Results
     [Documentation]  Check the Twamp Client Test Probes One Sample Results
     [Arguments]   ${test_size}  ${rtt_range}

     ${args}    evaluate     {'args':[{'test_size':'${test_size}'},{'rtt_range':'${rtt_range}'}]}
     Verify checks     checks=twamp_client_probes_current_results_sample_summary_check    devices=r0    args=${args}

Verify Twamp Client Test Session
     [Documentation]  Check the Twamp Client Test Session
     [Arguments]   ${connection_name}   ${session_name}   ${sender_addr}   ${reflector_addr}

     ${args}    evaluate     {'args':[{'connection_name':'${connection_name}'},{'session_name':'${session_name}'},{'sender_addr':'${sender_addr}'},{'reflector_addr':'${reflector_addr}'}]}
     Verify checks     checks=twamp_client_session_basic_check    devices=r0    args=${args}

Verify Twamp Client Control Connection is Stopped
     [Documentation]  Check the Twamp Client Control Connection is Stopped

     ${response}    execute cli command on device    device=${client}   command=show services rpm twamp client connection
     should contain    ${response}     error: Control-connection  does not exist

Verify Twamp Client Test Session is Stopped
     [Documentation]  Check the Twamp Client Test Session is Stopped

     ${response}    execute cli command on device    device=${client}   command=show services rpm twamp client session
     should match regexp    ${response}    \s*


Configure Twamp Server maximum connections
     [Documentation]  Config the Twamp Server maximum-connections
     [Arguments]  ${connection_cnt}

     @{cmd_list}     create list
     ...             set services rpm twamp server maximum-connections ${connection_cnt}
     ...             commit

     execute config command on device      device=${server}   command_list=@{cmd_list}


Configure Twamp Server maximum connections per client
     [Documentation]  Config the Twamp Server maximum-connections-per-client
     [Arguments]  ${connection_cnt_percli}

     @{cmd_list}     create list
     ...             set services rpm twamp server maximum-connections-per-client ${connection_cnt_percli}
     ...             commit

     execute config command on device      device=${server}   command_list=@{cmd_list}

Configure Twamp Client for sessions default scaling
    [Documentation]  Config the twamp client multiple sessions for scaling
    [Arguments]

    Config Engine   load_file=default_max_sessions.conf   option=set   resolve_vars=True   device_list=r0    commit=true   commit_timeout=${120}
    sleep   30s

Configure Twamp Client for sessions baseline scaling
    [Documentation]  Config the twamp client baseline sessions for scaling
    [Arguments]

    Config Engine   load_file=baseline_max_sessions.conf   option=set   resolve_vars=True   device_list=r0    commit=true   load_timeout=${150}   commit_timeout=${150}
    sleep   30s

Configure Twamp Client1 for sessions baseline scaling
    [Documentation]  Config the twamp client baseline sessions for scaling
    [Arguments]

    Config Engine   load_file=baseline_max_sessions1.conf   option=set   resolve_vars=True   device_list=r0    commit=true   load_timeout=${150}   commit_timeout=${150}
    sleep   30s

Configure Twamp Client2 for sessions baseline scaling
    [Documentation]  Config the twamp client2 baseline sessions for scaling
    [Arguments]

    Config Engine   load_file=baseline_max_sessions2.conf   option=set   resolve_vars=True   device_list=r2    commit=true   load_timeout=${150}   commit_timeout=${150}
    sleep   30s

Config the twamp client1 for connections scaling
    [Documentation]  Config the twamp client1 connections for scaling

    Config Engine   load_file=baseline_max_connections1.conf   option=set   resolve_vars=True   device_list=r0    commit=true   load_timeout=${150}   commit_timeout=${150}
    sleep   30s

Config the twamp client2 for connections scaling
    [Documentation]  Config the twamp client2 connections for scaling

    Config Engine   load_file=baseline_max_connections2.conf   option=set   resolve_vars=True   device_list=r2    commit=true  load_timeout=${150}   commit_timeout=${150}
    sleep   30s

Config the twamp server in middle node
    [Documentation]  Configure Twamp Server on middle node
    [Arguments]   ${client1_nw}   ${client2_nw}

    @{cmd_list}      create list
    ...              set services rpm twamp server authentication-mode none
    ...              set services rpm twamp server client-list client1 address ${client1_nw}
    ...              set services rpm twamp server client-list client2 address ${client2_nw}
    ...              commit

     execute config command on device      device=${r1}   command_list=@{cmd_list}   timeout=${150}


Congiure Twamp Server Maximum Sessions
   [Documentation]  Config the twamp server max sessions
   [Arguments]  ${session_cnt}

    @{cmd_list}     create list
     ...             set services rpm twamp server maximum-sessions ${session_cnt}
     ...             commit

     execute config command on device      device=${server}   command_list=@{cmd_list}  timeout=${120}
     sleep   5s

Congiure Twamp Server Maximum Sessions on Middle Node
   [Documentation]  Config the twamp server max sessions
   [Arguments]  ${session_cnt}

    @{cmd_list}     create list
     ...             set services rpm twamp server maximum-sessions ${session_cnt}
     ...             commit

     execute config command on device      device=${r1}   command_list=@{cmd_list}  timeout=${120}
     sleep   5s

Delete one session under the connection
   [Documentation]  Delete one test session under the connection
   [Arguments]  ${session}

    @{cmd_list}     create list
     ...             delete services rpm twamp client control-connection c1 test-session ${session}
     ...             commit

     execute config command on device      device=${client}   command_list=@{cmd_list}  timeout=${120}
     sleep   5s

Add one more session under connection
   [Documentation]  Add one more test session under the connection
   [Arguments]  ${session}  ${server_addr}

    @{cmd_list}     create list
     ...             set services rpm twamp client control-connection c1 test-session ${session} target-address ${server_addr}
     ...             set services rpm twamp client control-connection c1 test-session ${session} probe-count 2000
     ...             commit

     execute config command on device      device=${client}   command_list=@{cmd_list}  timeout=${120}
     sleep   5s

Congiure Twamp Server Maximum Sessions Per Connecton
   [Documentation]  Config the twamp server max sessions per connections
   [Arguments]  ${session_cnt_percon}

    @{cmd_list}     create list
     ...             set services rpm twamp server maximum-sessions-per-connection ${session_cnt_percon}
     ...             commit

     execute config command on device      device=${server}   command_list=@{cmd_list}   timeout=${150}
     sleep   5s

Congiure Twamp Server Maximum Sessions Per Connecton on Middle node
   [Documentation]  Config the twamp server max sessions per connections
   [Arguments]  ${session_cnt_percon}

    @{cmd_list}     create list
     ...             set services rpm twamp server maximum-sessions-per-connection ${session_cnt_percon}
     ...             commit

     execute config command on device      device=${r1}   command_list=@{cmd_list}   timeout=${150}
     sleep   5s

Configure Twamp Server maximum sessions in Middle Node
    [Documentation]  Config the twamp server max-sessions on middle node
    [Arguments]  ${session_cnt}

    @{cmd_list}     create list
     ...             set services rpm twamp server maximum-sessions ${session_cnt}
     ...             commit

     execute config command on device      device=${r1}   command_list=@{cmd_list}  timeout=${150}
     sleep   5s

Configure Twamp Server maximum-connections in Middle Node
   [Documentation]  Configure Twamp Server maximum-connections in Middle Node
   [Arguments]  ${connection_cnt}

    @{cmd_list}     create list
     ...             set services rpm twamp server maximum-connections ${connection_cnt}
     ...             commit

     execute config command on device      device=${r1}   command_list=@{cmd_list}   timeout=${150}
     sleep   5s

Configure Twamp Server maximum-connections-per-client in Middle Node
   [Documentation]  Configure Twamp Server maximum-connections-per-client in Middle Node
   [Arguments]  ${connection_cnt_percli}

   @{cmd_list}     create list
    ...             set services rpm twamp server maximum-connections-per-client ${connection_cnt_percli}
    ...             commit

    execute config command on device      device=${r1}   command_list=@{cmd_list}   timeout=${150}
    sleep   5s

Configure Twamp Server max-connection-duration
    [Documentation]  Configure twamp server max-connection-duration

    @{cmd_list}     create list
    ...             set services rpm twamp server max-connection-duration 1
    ...             commit

    execute config command on device      device=${server}   command_list=@{cmd_list}  timeout=${120}
    sleep   5s

Configure Twamp Server inactivity timeout
    [Documentation]  Config twamp server server-inactivity-timeout
    [Arguments]  ${timeout}

    @{cmd_list}     create list
     ...             set services rpm twamp server server-inactivity-timeout ${timeout}
     ...             commit

     execute config command on device      device=${server}   command_list=@{cmd_list}   timeout=${150}
     sleep   5s

Clear Twamp Server Connction All
   [Documentation]  Clear all the server connection

   execute cli command on device     device=${server}    command=clear services rpm twamp server connection

Clear Twamp Server Connection ID
   [Documentation]  Clear the server connection ID
   [Arguments]  ${ID}

   execute cli command on device     device=${server}    command=clear services rpm twamp server connection ${ID}

Get Connection ID on Twamp Server
   [Documentation]   Get the connection id on Twamp Server

    ${connections}     execute cli command on device     device=${server}    command=show services rpm twamp server connection | display xml
    ${id}   get element text     ${connections}    twamp-server-information/connection/connection-id
    [Return]   ${id}

Verify Twamp Server Max Connections Count
    [Documentation]  Check max-connections options
    [Arguments]  ${connections_cnt}

    ${connections}     execute cli command on device     device=${server}    command=show services rpm twamp server connection | display xml
    ${cnt_get}   get element count    ${connections}    twamp-server-information/connection/connection-id
    should be equal   ${connections_cnt}    ${cnt_get}

Verify Twamp Server Max Connections Count on middle node
    [Documentation]  Check max-connections options
    [Arguments]  ${connections_cnt}

    ${connections}     execute cli command on device     device=${r1}    command=show services rpm twamp server connection | display xml
    ${cnt_get}   get element count    ${connections}    twamp-server-information/connection/connection-id
    should be equal   ${connections_cnt}   ${cnt_get}

Verify Twamp Server Total Session Count
    [Documentation]  Check Twamp Server Tatal Sessions Count
    [Arguments]  ${session_cnt}

    ${sessions}     execute cli command on device     device=${server}    command=show services rpm twamp server session | display xml
    ${cnt_get}   get element count    ${sessions}    twamp-server-information/server/session/session-id
    should be equal   ${session_cnt}   ${cnt_get}

Verify Twamp Server Total Session Count in middle node
    [Documentation]  Check Twamp Server Tatal Sessions Count
    [Arguments]  ${session_cnt}

    ${sessions}     execute cli command on device     device=${r1}    command=show services rpm twamp server session | display xml
    ${cnt_get}   get element count    ${sessions}    twamp-server-information/server/session/session-id
    should be equal   ${session_cnt}   ${cnt_get}


Verify Twamp Server Sesson Count Per Connection
    [Documentation]   Check Twamp Server session count per connection
    [Arguments]  ${sess_cnt_conn}
    ${connections}     execute cli command on device     device=${server}    command=show services rpm twamp server connection | display xml
    ${cnt_get}   get element text    ${connections}    twamp-server-information/connection/session-count
    should be equal   ${sess_cnt_conn}   ${cnt_get}

Verify Twamp Server Sesson Count Per Connection in middle node
    [Documentation]   Check Twamp Server session count per connection
    [Arguments]  ${sess_cnt_conn}
    ${connections}     execute cli command on device     device=${r1}    command=show services rpm twamp server connection | display xml
    ${cnt_get}   get element text    ${connections}    twamp-server-information/connection/session-count[1]
    should be equal   ${sess_cnt_conn}   ${cnt_get}

Verify Twamp Server the connection and session exist
    [Documentation]  Check the twamp server exist the connection and session

    ${sessions}     execute cli command on device     device=${server}    command=show services rpm twamp server session | display xml
    ${s_cnt_get}   get element count    ${sessions}    twamp-server-information/server/session-id
    should be true    ${s_cnt_get}>=1
    ${connections}     execute cli command on device     device=${server}    command=show services rpm twamp server connection | display xml
    ${c_cnt_get}   get element count    ${connections}    twamp-server-information/connection/connection-id
    should be true    ${c_cnt_get}>=1

Verify Twamp Server the connection and session not exist
    [Documentation]  Check the twamp server connection and session are deleted
    sleep  5s
    ${response1}    execute cli command on device    device=${server}   command=show services rpm twamp server connection| display xml   timeout=${120}
    ${cnt}   get element count    ${response1}     twamp-server-information/connection/connection-id
    should be true    ${cnt}==0
    ${response2}    execute cli command on device    device=${server}   command=show services rpm twamp server session| display xml    timeout=${120}
    ${cnt2}   get element count    ${response2}     twamp-server-information/server/session-id
    should be true    ${cnt2}==0

Configure Twamp Client Connection Destination Port
     [Documentation]  Config the Twamp Client Desination Port
     [Arguments]  ${connection_name}  ${port}

     @{cmd_list}     create list
     ...             set services rpm twamp client control-connection ${connection_name} destination-port ${port}
     ...             commit

     execute config command on device      device=${client}   command_list=@{cmd_list}   timeout=${120}

Configure Twamp Server Port
     [Documentation]  Config the Twamp Client Desination Port
     [Arguments]  ${port}

     @{cmd_list}     create list
     ...             set services rpm twamp server port ${port}
     ...             commit

     execute config command on device      device=${server}   command_list=@{cmd_list}   timeout=${150}

Verify Twamp Server Connection Port
     [Documentation]  Check Twamp Server port
     [Arguments]  ${port}

     ${connection}     execute cli command on device     device=${server}    command=show services rpm twamp server connection | display xml
     ${port_get}   get element text   ${connection}    twamp-server-information/connection/server-port
     ${port_num}   evaluate    ${port_get}
     should be equal   ${port}   ${port_num}

Configure Routing Instance on Twamp Server
     [Documentation]  Config the Routing Instance on Twamp Server
     [Arguments]  ${instance_name}  ${interface}  ${client_ip}

     @{cmd_list}     create list
     ...             set routing-instances ${instance_name} interface ${interface}
     ...             set routing-instances ${instance_name} instance-type virtual-router
     ...             commit

     execute config command on device      device=${server}   command_list=@{cmd_list}   timeout=${150}
     sleep  20s
     ${response}  execute cli command on device     device=${server}    command=ping routing-instance ${instance_name} ${client_ip} count 10
     should not contain     ${response}    100% packet loss

Config Routing Instance on Twamp Server for three nodes
    [Documentation]  Config the Routing Instance on Twamp Server for three nodes
    [Arguments]  ${instance_name}  ${interface}  ${client_ip}  ${nexthop_ip}

    @{cmd_list}     create list
     ...             set routing-instances ${instance_name} interface ${interface}
     ...             set routing-instances ${instance_name} instance-type virtual-router
     ...             set routing-instances ${instance_name} routing-options static route ${client_ip} next-hop ${nexthop_ip}
     ...             commit

     execute config command on device      device=${server}   command_list=@{cmd_list}   timeout=${150}
     sleep  20s
     ${response}  execute cli command on device     device=${server}    command=ping routing-instance ${instance_name} ${client_ip} count 10
     should not contain     ${response}    100% packet loss

Configure Routing Instance Options In TWAMP Server
     [Documentation]  Config the Routing Instance options in twamp Server
     [Arguments]  ${instance}  ${port}

     @{cmd_list}     create list
     ...             set services rpm twamp server routing-instance-list ${instance} port ${port}
     ...             commit

     execute config command on device      device=${server}   command_list=@{cmd_list}    timeout=${150}

Restore the routing instance to default
   [Documentation]  Restore the routing instance to default

   @{cmd_list}     create list
   ...             delete services rpm twamp server routing-instance-list
   ...             delete routing-instances ${tv['uv-routing-instance']}
   ...             commit

     execute config command on device      device=${server}   command_list=@{cmd_list}   timeout=${180}

Restore the interface with no policy for three nodes
   [Documentation]  Restore the routing instance to default

   @{cmd_list}     create list
   ...             delete interfaces ${tv['r2__r2r1__pic']} unit 0 family inet filter
   ...             commit

   execute config command on device      device=${server}   command_list=@{cmd_list}

Restore the interface with no policy
   [Documentation]  Restore the routing instance to default

   @{cmd_list}     create list
   ...             delete interfaces ${tv['r1__r1r0__pic']} unit 0 family inet filter
   ...             commit

   execute config command on device      device=${server}   command_list=@{cmd_list}  timeout=${120}

Restore the interface with no policy for HA
   [Documentation]  Restore the routing instance to default

   @{cmd_list}     create list
   ...             delete interfaces reth0 unit 0 family inet filter
   ...             commit

   execute config command on device      device=${server}   command_list=@{cmd_list}    timeout=${180}

Restore the interface with no policy for LAG
   [Documentation]  Restore the routing instance to default

   @{cmd_list}     create list
   ...             delete interfaces ae0 unit 0 family inet filter
   ...             commit

   execute config command on device      device=${server}   command_list=@{cmd_list}   timeout=${120}

Configure Firewall Filter to Discard Twamp Packets
    [Documentation]  Configure Firewall Filter on Twamp Server
    [Arguments]  ${client_ip}  ${interface}

    @{cmd_list}     create list
     ...             set firewall filter twamp_discard term term1 from source-address ${client_ip}
     ...             set firewall filter twamp_discard term term1 then discard
     ...             set interfaces ${interface} unit 0 family inet filter input twamp_discard
     ...             commit

     execute config command on device      device=${server}   command_list=@{cmd_list}    timeout=${150}
     sleep  10s

Configure Firewall Filter to Permit the Twamp Packets
    [Documentation]  Configure the firewall filter to permit twamp packets
    [Arguments]  ${client_ip}   ${interface}

     @{cmd_list}     create list
     ...             set firewall filter twamp_permit term term1 from source-address ${client_ip}
     ...             set firewall filter twamp_permit term term1 then accept
     ...             set interfaces ${interface} unit 0 family inet filter input twamp_permit
     ...             commit

     execute config command on device      device=${server}   command_list=@{cmd_list}   timeout=${150}
     sleep   10s


Remove the twamp Client from Client list
    [Documentation]  Remove the valid client from the client list
    [Arguments]  ${client_nm}

    @{cmd_list}     create list
     ...             delete services rpm twamp server client-list client1 address ${client_nm}
     ...             commit

     execute config command on device      device=${server}   command_list=@{cmd_list}
     sleep  5s

Restart RMOPD Process
     [Documentation]  Restart the ROMPD Process

     execute cli command on device     device=${server}    command=restart remote-operations
     sleep  10s

Restart Chassis Control
     [Documentation]  Restart the Chassis Control

     execute cli command on device     device=${server}    command=restart chassis-control    timeout=${150}
     sleep  300s

Disable Twamp Server Interface
     [Documentation]  Disable Twamp Client Interface
     [Arguments]  ${interface}

     @{cmd_list}     create list
     ...             set interfaces ${interface} disable
     ...             commit

     execute config command on device      device=${server}   command_list=@{cmd_list}
     sleep  10s

Enable Twamp Server Interface
     [Documentation]  Enable Twamp Client Interface
     [Arguments]  ${interface}

     @{cmd_list}     create list
     ...             delete interfaces ${interface} disable
     ...             commit

     execute config command on device      device=${server}   command_list=@{cmd_list}
     sleep  30s

     ${response}  execute cli command on device     device=${server}    command=ping ${tv['uv-r0_r1-ip']} count 10
     should not contain   ${response}    100% packet loss


Deactivate RPM Service Process
     [Documentation]  Deactivate RPM Service Process

     @{cmd_list}     create list
     ...             deactivate services rpm
     ...             commit

     execute config command on device      device=${server}   command_list=@{cmd_list}
     sleep  5s

Activate RPM Service Process
     [Documentation]  Activate RPM Service Process

     @{cmd_list}     create list
     ...             activate services rpm
     ...             commit

     execute config command on device      device=${server}   command_list=@{cmd_list}
     sleep  5s

Restart Twamp Server System
     [Documentation]  Restart the Twamp Server System

     reboot device      device=${server}     timeout=${480}
     sleep  40s

Verify CLI Knob client address Constraints
    [Documentation]  check CLI Knob client-list address constraints

    @{cmd_list}     create list
     ...             set services rpm twamp server client-list client address 255.255.255.255
     ...             commit
    ${result}  ${response}  run keyword and ignore error    execute config command on device      device=${server}   command_list=@{cmd_list}
    should contain    ${response}    Invalid IP address for twamp client list

    @{cmd_list}     create list
    ...             set services rpm twamp server client-list client address 0.0.0.0
    ...             commit
    ${result}  ${response}  run keyword and ignore error   execute config command on device      device=${server}   command_list=@{cmd_list}
    should contain    ${response}    Invalid IP address for twamp client list

    @{cmd_list}     create list
    ...             set services rpm twamp server client-list client address s.s.s.s
    ${result}  ${response}  run keyword and ignore error  execute config command on device      device=${server}   command_list=@{cmd_list}
    should contain    ${response}    could not resolve name

    @{cmd_list}     create list
    ...             set services rpm twamp server client-list client address 1.2.3.256
    ${result}  ${response}  run keyword and ignore error  execute config command on device      device=${server}   command_list=@{cmd_list}
    should contain    ${response}    invalid value '256' in ip address

    @{cmd_list}     create list
    ...             set services rpm twamp server client-list client address 2:2:2:2
    ${result}  ${response}  run keyword and ignore error  execute config command on device      device=${server}   command_list=@{cmd_list}
    should contain    ${response}    invalid ip address or hostname

    @{cmd_list}     create list
    ...             delete services rpm twamp server client-list client address 0.0.0.0
    ...             delete services rpm twamp server client-list client address 255.255.255.255
    ...             commit
    execute config command on device      device=${server}   command_list=@{cmd_list}


Verify CLI Knob port Constraints
    [Documentation]  check CLI Knob port constraints

    @{cmd_list}     create list
     ...             set services rpm twamp server port -1
    ${result}  ${response}  run keyword and ignore error  execute config command on device      device=${server}   command_list=@{cmd_list}
    should contain    ${response}    Invalid numeric value

    @{cmd_list}     create list
     ...             set services rpm twamp server port 0
    ${result}  ${response}  run keyword and ignore error  execute config command on device      device=${server}   command_list=@{cmd_list}
    should contain    ${response}    Value 0 is not within range

    @{cmd_list}     create list
     ...             set services rpm twamp server port 65537
    ${result}  ${response}  run keyword and ignore error  execute config command on device      device=${server}   command_list=@{cmd_list}
    should contain    ${response}    Value 65537 is not within range

Verify CLI Knob max-connection-duration Constraints
    [Documentation]  check CLI Knob max-connection-duration constraints

    @{cmd_list}     create list
     ...             set services rpm twamp server max-connection-duration -1
    ${result}  ${response}  run keyword and ignore error  execute config command on device      device=${server}   command_list=@{cmd_list}
    should contain    ${response}    Invalid numeric value

    @{cmd_list}     create list
     ...             set services rpm twamp server max-connection-duration 121
    ${result}  ${response}  run keyword and ignore error  execute config command on device      device=${server}   command_list=@{cmd_list}
    should contain    ${response}    Value 121 is not within range


Verify CLI Knob maximum-connections Constraints
    [Documentation]  check CLI Knob maximum-connections constraints

    @{cmd_list}     create list
     ...             set services rpm twamp server maximum-connections -1
    ${result}  ${response}  run keyword and ignore error  execute config command on device      device=${server}   command_list=@{cmd_list}
    should contain    ${response}    Invalid numeric value

    @{cmd_list}     create list
     ...             set services rpm twamp server maximum-connections 1001
    ${result}  ${response}  run keyword and ignore error  execute config command on device      device=${server}   command_list=@{cmd_list}
    should contain    ${response}    Value 1001 is not within range

Verify CLI Knob maximum-connections-per-client Constraints
    [Documentation]  check CLI Knob maximum-connections-per-client constraints

    @{cmd_list}     create list
     ...             set services rpm twamp server maximum-connections-per-client -10
    ${result}  ${response}  run keyword and ignore error  execute config command on device      device=${server}   command_list=@{cmd_list}
    should contain    ${response}    Invalid numeric value

    @{cmd_list}     create list
     ...             set services rpm twamp server maximum-connections-per-client 0
    ${result}  ${response}  run keyword and ignore error  execute config command on device      device=${server}   command_list=@{cmd_list}
    should contain    ${response}    Value 0 is not within range

    @{cmd_list}     create list
     ...             set services rpm twamp server maximum-connections-per-client 501
    ${result}  ${response}  run keyword and ignore error  execute config command on device      device=${server}   command_list=@{cmd_list}
    should contain    ${response}    Value 501 is not within range

Verify CLI Knob maximum-sessions Constraints
    [Documentation]  check CLI Knob maximum-sessions constraints

    @{cmd_list}     create list
     ...             set services rpm twamp server maximum-sessions -10
    ${result}  ${response}  run keyword and ignore error   execute config command on device      device=${server}   command_list=@{cmd_list}
    should contain    ${response}    Invalid numeric value

    @{cmd_list}     create list
     ...             set services rpm twamp server maximum-sessions 0
    ${result}  ${response}  run keyword and ignore error   execute config command on device      device=${server}   command_list=@{cmd_list}
    should contain    ${response}    Value 0 is not within range

    @{cmd_list}     create list
     ...             set services rpm twamp server maximum-sessions 2049
    ${result}  ${response}  run keyword and ignore error  execute config command on device      device=${server}   command_list=@{cmd_list}
    should contain    ${response}    Value 2049 is not within range

Verify CLI Knob maximum-sessions-per-connection Constraints
    [Documentation]  check CLI Knob maximum-sessions-per-connection constraints

    @{cmd_list}     create list
     ...             set services rpm twamp server maximum-sessions-per-connection -1
    ${result}  ${response}  run keyword and ignore error  execute config command on device      device=${server}   command_list=@{cmd_list}
    should contain    ${response}    Invalid numeric value

    @{cmd_list}     create list
     ...             set services rpm twamp server maximum-sessions-per-connection 0
    ${result}  ${response}  run keyword and ignore error   execute config command on device      device=${server}   command_list=@{cmd_list}
    should contain    ${response}    Value 0 is not within range

    @{cmd_list}     create list
     ...             set services rpm twamp server maximum-sessions-per-connection 1025
    ${result}  ${response}  run keyword and ignore error  execute config command on device      device=${server}   command_list=@{cmd_list}
    should contain    ${response}    Value 1025 is not within range

Verify CLI Knob server-inactivity-timeout Constraints
    [Documentation]  check CLI Knob server-inactivity-timeout constraints

    @{cmd_list}     create list
     ...             set services rpm twamp server server-inactivity-timeout -1
    ${result}  ${response}  run keyword and ignore error  execute config command on device      device=${server}   command_list=@{cmd_list}
    should contain    ${response}    Invalid numeric value

    @{cmd_list}     create list
     ...             set services rpm twamp server server-inactivity-timeout 31
    ${result}  ${response}  run keyword and ignore error    execute config command on device      device=${server}   command_list=@{cmd_list}
    should contain    ${response}    Value 31 is not within range


Verify CLI Knob client address configure and delete
    [Documentation]  check client address configure and delete

    @{cmd_list}     create list
    ...             set services rpm twamp server client-list client address 1.1.1.1
    ...             commit
    ${response}  execute config command on device      device=${server}   command_list=@{cmd_list}
    should contain    ${response}    commit complete

     @{cmd_list}     create list
    ...             delete services rpm twamp server client-list client address 1.1.1.1
    ...             commit
    ${response}  execute config command on device      device=${server}   command_list=@{cmd_list}
    should contain    ${response}    commit complete

Verify CLI Knob max-connection-duration configure and delete
    [Documentation]  Check max-connection-duration configure and delete

    @{cmd_list}     create list
    ...             set services rpm twamp server max-connection-duration 120
    ...             commit
    ${response}  execute config command on device      device=${server}   command_list=@{cmd_list}
    should contain    ${response}    commit complete

     @{cmd_list}     create list
    ...             delete services rpm twamp server max-connection-duration 120
    ...             commit
    ${response}  execute config command on device      device=${server}   command_list=@{cmd_list}
    should contain    ${response}    commit complete

Verify CLI Knob routing instance configure and delete
    [Documentation]  Check maximum-connections configure and delete
    [Arguments]  ${interface}

    @{cmd_list}     create list
    ...             set routing-instances twamp interface ${interface}
    ...             set services rpm twamp server routing-instance-list twamp port 1000
    ...             commit
    ${response}  execute config command on device      device=${server}   command_list=@{cmd_list}
    should contain    ${response}    commit complete

     @{cmd_list}     create list
    ...             delete services rpm twamp server routing-instance-list twamp
    ...             delete routing-instances twamp
    ...             commit
    ${response}  execute config command on device      device=${server}   command_list=@{cmd_list}
    should contain    ${response}    commit complete

Verify CLI Knob maximum-connections configure and delete
    [Documentation]  Check maximum-connections configure and delete

    @{cmd_list}     create list
    ...             set services rpm twamp server maximum-connections 1000
    ...             commit
    ${response}  execute config command on device      device=${server}   command_list=@{cmd_list}
    should contain    ${response}    commit complete

     @{cmd_list}     create list
     ...             delete services rpm server maximum-connections 1000
     ...             commit
     ${response}  execute config command on device      device=${server}   command_list=@{cmd_list}
     should contain    ${response}    commit complete

Verify CLI Knob maximum-connections-per-client configure and delete
    [Documentation]  check maximum-connections-per-client configure and delete

    @{cmd_list}     create list
    ...             set services rpm twamp server maximum-connections-per-client 500
    ...             commit
    ${response}  execute config command on device      device=${server}   command_list=@{cmd_list}
    should contain    ${response}    commit complete

     @{cmd_list}     create list
     ...             delete services rpm twamp server maximum-connections-per-client 500
     ...             commit
     ${response}  execute config command on device      device=${server}   command_list=@{cmd_list}
     should contain    ${response}    commit complete

Verify CLI Knob maximum-sessions configure and delete
     [Documentation]  check maximum-sessions configure and delete

     @{cmd_list}     create list
     ...             set services rpm twamp server maximum-sessions 2048
     ...             commit
     ${response}  execute config command on device      device=${server}   command_list=@{cmd_list}
        should contain    ${response}    commit complete

     @{cmd_list}     create list
     ...             delete services rpm twamp server maximum-sessions 2048
     ...             commit
     ${response}  execute config command on device      device=${server}   command_list=@{cmd_list}
     should contain    ${response}    commit complete

Verify CLI Knob maximum-sessions-per-connection configure and delete
     [Documentation]  check maximum-sessions-per-connection configure and delete

     @{cmd_list}     create list
     ...             set services rpm twamp server maximum-sessions-per-connection 64
     ...             commit
     ${response}  execute config command on device      device=${server}   command_list=@{cmd_list}
        should contain    ${response}    commit complete

     @{cmd_list}     create list
     ...             delete services rpm twamp server maximum-sessions-per-connection 64
     ...             commit
     ${response}  execute config command on device      device=${server}   command_list=@{cmd_list}
     should contain    ${response}    commit complete

Verify CLI Knob server-inactivity-timeout configure and delete
     [Documentation]  Check server-inactivity-timeout configure and delete

     @{cmd_list}     create list
     ...             set services rpm twamp server server-inactivity-timeout 30
     ...             commit
     ${response}  execute config command on device      device=${server}   command_list=@{cmd_list}
     should contain    ${response}    commit complete

     @{cmd_list}     create list
     ...             delete services rpm twamp server-inactivity-timeout 30
     ...             commit
     ${response}  execute config command on device      device=${server}   command_list=@{cmd_list}
     should contain    ${response}    commit complete


Break one link of LAG interface
    [Documentation]  Break one link of LAG interface
    [Arguments]  ${interface}


     @{cmd_list}     create list
     ...             set interfaces ${interface} disable
     ...             commit
     ${response}   execute config command on device      device=${server}   command_list=@{cmd_list}  timeout=${150}

Restore the link of LAG interface
    [Documentation]  Restore the link of LAG interface
    [Arguments]  ${interface}


     @{cmd_list}     create list
     ...             delete interfaces ${interface} disable
     ...             commit
     ${response}   execute config command on device      device=${server}   command_list=@{cmd_list}  timeout=${150}





