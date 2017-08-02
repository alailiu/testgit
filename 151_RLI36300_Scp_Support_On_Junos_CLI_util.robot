
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
    \      ...             set system domain-search [englab.juniper.net]
    \      Config Engine   device_list=${device}  cmd_list=@{cmd_list}   commit=true   commit_timeout=${120}

    sleep    5s

Change the mgt inface of security zone for Flow Mode
    [Documentation]  Change the mgt interface to the groups global security zone
    [Arguments]  @{device_list}

    :FOR   ${device}    IN     @{device_list}
    \      @{cmd_list}     create list
    \      ...             delete groups global security zones security-zone HOST interfaces
    \      ...             set groups global security zones security-zone HOST interfaces ${t['resources']['${device}']['system']['primary']['controllers']['re0']['mgt-intf-name']}
    \      Config Engine   device_list=${device}  cmd_list=@{cmd_list}   commit=true   commit_timeout=${120}



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
    set suite variable      ${client}      ${r1}
    set suite variable      ${server}      ${r0}
    set suite variable      ${client_node}     r1
    set suite variable      ${server_node}     r0
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



Init the Configurations on two nodes in Flow Mode
    [Documentation]   Init configurations on two devices which in flow mode
    #Init the configuration on the devices
    @{cmd_list_r0}     create list
    ...                set interfaces ${tv['r0__r0r1__pic']} unit 0 family inet address ${tv['uv-r0_r1-ip']}/${tv['uv-mask']}
    ...                set interfaces ${tv['r0__r0r1__pic']} unit 0 family inet6 address ${tv['uv-r0_r1-ip6']}/${tv['uv-mask6']}
    ...                set interfaces ${tv['r0__r0r1_2__pic']} unit 0 family inet address ${tv['uv-r0_r1-ip2']}/${tv['uv-mask']}
    ...                set interfaces ${tv['r0__r0r1_2__pic']} unit 0 family inet6 address ${tv['uv-r0_r1-ip62']}/${tv['uv-mask6']}
    ...                set interfaces lo0 unit 0 family inet address ${tv['uv-r0_r1-ip-lo']}/${tv['uv-mask']}
    ...                set interfaces lo0 unit 0 family inet6 address ${tv['uv-r0_r1-ip6-lo']}/${tv['uv-mask6']}
    ...                set interfaces lo0 unit 1 family inet address ${tv['uv-r0_r1-ip-lo2']}/${tv['uv-mask']}
    ...                set interfaces lo0 unit 1 family inet6 address ${tv['uv-r0_r1-ip6-lo2']}/${tv['uv-mask6']}
    ...                set security zones security-zone trust host-inbound-traffic system-services all
    ...                set security zones security-zone trust host-inbound-traffic protocols all
    ...                set security policies default-policy permit-all
    ...                set security zones security-zone trust interfaces ${tv['r0__r0r1__pic']}
    ...                set security zones security-zone trust interfaces lo0.0
    ...                set security zones security-zone trust2 host-inbound-traffic system-services all
    ...                set security zones security-zone trust2 host-inbound-traffic protocols all
    ...                set security zones security-zone trust2 interfaces ${tv['r0__r0r1_2__pic']}
    ...                set security zones security-zone trust2 interfaces lo0.1
    ...                set routing-options static route ${tv['uv-r1_r0-nm-lo']} next-hop ${tv['uv-r1_r0-ip']}
    ...                set routing-options rib inet6.0 static route ${tv['uv-r1_r0-nm6-lo']} next-hop ${tv['uv-r1_r0-ip6']}
    ...                set routing-instances N1 instance-type virtual-router
    ...                set routing-instances N1 interface ${tv['r0__r0r1_2__pic']}.0
    ...                set routing-instances N1 interface lo0.1
    ...                set routing-instances N1 routing-options static route ${tv['uv-r1_r0-nm-lo']} next-hop ${tv['uv-r1_r0-ip2']}
    ...                set routing-instances N1 routing-options rib N1.inet6.0 static route ${tv['uv-r1_r0-nm6-lo']} next-hop ${tv['uv-r1_r0-ip62']}
    ...                commit
    execute config command on device      device=${r0}   command_list=@{cmd_list_r0}   timeout=${150}

    @{cmd_list_r1}     create list
    ...                set interfaces ${tv['r1__r1r0__pic']} unit 0 family inet address ${tv['uv-r1_r0-ip']}/${tv['uv-mask']}
    ...                set interfaces ${tv['r1__r1r0__pic']} unit 0 family inet6 address ${tv['uv-r1_r0-ip6']}/${tv['uv-mask6']}
    ...                set interfaces ${tv['r1__r1r0_2__pic']} unit 0 family inet address ${tv['uv-r1_r0-ip2']}/${tv['uv-mask']}
    ...                set interfaces ${tv['r1__r1r0_2__pic']} unit 0 family inet6 address ${tv['uv-r1_r0-ip62']}/${tv['uv-mask6']}
    ...                set interfaces lo0 unit 0 family inet address ${tv['uv-r1_r0-ip-lo']}/${tv['uv-mask']}
    ...                set interfaces lo0 unit 0 family inet6 address ${tv['uv-r1_r0-ip6-lo']}/${tv['uv-mask6']}
    ...                set security zones security-zone trust host-inbound-traffic system-services all
    ...                set security zones security-zone trust host-inbound-traffic protocols all
    ...                set security policies default-policy permit-all
    ...                set security zones security-zone trust interfaces ${tv['r1__r1r0__pic']}
    ...                set security zones security-zone trust interfaces ${tv['r1__r1r0_2__pic']}
    ...                set security zones security-zone trust interfaces lo0.0
    ...                set routing-options static route ${tv['uv-r0_r1-nm-lo']} next-hop ${tv['uv-r0_r1-ip']}
    ...                set routing-options rib inet6.0 static route ${tv['uv-r0_r1-nm6-lo']} next-hop ${tv['uv-r0_r1-ip6']}
    ...                set routing-options static route ${tv['uv-r0_r1-nm-lo2']} next-hop ${tv['uv-r0_r1-ip2']}
    ...                set routing-options rib inet6.0 static route ${tv['uv-r0_r1-nm6-lo2']} next-hop ${tv['uv-r0_r1-ip62']}
    ...                commit
    execute config command on device      device=${r1}   command_list=@{cmd_list_r1}   timeout=${150}

    sleep   20s
    ${response1}   execute cli command on device    device=${client}   command=ping ${target_addr} count 10
    should not contain     ${response1}     100% packet loss
    ${response1}   execute cli command on device    device=${client}   command=ping ${tv['uv-r1_r0-ip-lo']} source ${tv['uv-r0_r1-ip-lo']} count 10
    should not contain     ${response1}     100% packet loss
    ${response1}   execute cli command on device    device=${client}   command=ping ${tv['uv-r1_r0-ip-lo']} routing-instance N1 source ${tv['uv-r0_r1-ip-lo2']} count 10
    should not contain     ${response1}     100% packet loss
    ${response2}   execute cli command on device    device=${client}   command=ping ${tv['uv-r1_r0-ip6']} count 10
    should not contain     ${response2}     100% packet loss
    ${response2}   execute cli command on device    device=${client}   command=ping ${tv['uv-r1_r0-ip62']} routing-instance N1 count 10
    should not contain     ${response2}     100% packet loss
    ${response2}   execute cli command on device    device=${client}   command=ping ${tv['uv-r1_r0-ip6-lo']} source ${tv['uv-r0_r1-ip6-lo']} count 10
    should not contain     ${response2}     100% packet loss
    ${response2}   execute cli command on device    device=${client}   command=ping ${tv['uv-r1_r0-ip6-lo']} routing-instance N1 source ${tv['uv-r0_r1-ip6-lo2']} count 10
    should not contain     ${response2}     100% packet loss

    ${response2}   execute cli command on device    device=${client}   command=ping ${t['resources']['r1']['system']['primary']['controllers']['re0']['hostname']} count 30   timeout=${120}
    should not contain     ${response2}     100% packet loss
    #sleep   50000000s

Clear the Configurations on two nodes in Flow Mode
    [Documentation]   Init configurations on two devices which in flow mode
    #Init the configuration on the devices
    @{cmd_list_r0}     create list
    ...                delete interfaces
    ...                delete security
    ...                delete routing-options
    ...                delete routing-instances
    ...                commit
    execute config command on device      device=${r0}   command_list=@{cmd_list_r0}   timeout=${150}

    @{cmd_list_r1}     create list
    ...                delete interfaces
    ...                delete security
    ...                delete routing-options
    ...                delete routing-instances
    ...                commit
    execute config command on device      device=${r1}   command_list=@{cmd_list_r1}   timeout=${150}

    sleep   20s



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
    ...                set interfaces reth0 unit 0 family inet address ${tv['uv-r1_r0-ip']}/${tv['uv-mask']}
    ...                set security zones security-zone trust host-inbound-traffic system-services all
    ...                set security zones security-zone trust host-inbound-traffic protocols all
    ...                set security policies default-policy permit-all
    ...                set security zones security-zone trust interfaces reth0
    ...                commit
    execute config command on device      device=${r1}   command_list=@{cmd_list_r1}   timeout=${250}

    @{cmd_list_r0}     create list
    ...                set interfaces ${tv['r0__r0r1__pic']} unit 0 family inet address ${tv['uv-r0_r1-ip']}/${tv['uv-mask']}
    ...                set security zones security-zone trust host-inbound-traffic system-services all
    ...                set security zones security-zone trust host-inbound-traffic protocols all
    ...                set security policies default-policy permit-all
    ...                set security zones security-zone trust interfaces ${tv['r0__r0r1__pic']}
    ...                commit
    execute config command on device      device=${r0}   command_list=@{cmd_list_r0}   timeout=${250}

    sleep   30s
    ${response1}   execute cli command on device    device=${r0}   command=ping ${tv['uv-r1_r0-ip']} count 30
    should not contain     ${response1}     100% packet loss
    ${response2}   execute cli command on device    device=${r1}   command=ping ${tv['uv-r0_r1-ip']} count 30
    should not contain     ${response2}     100% packet loss


Clear the configurations of HA topology
    [Documentation]  Init the configuraitons of HA topo

    @{cmd_list_r1}     create list
    ...                delete chassis
    ...                delete interfaces
    ...                delete security
    ...                commit
    execute config command on device      device=${r1}   command_list=@{cmd_list_r1}   timeout=${250}

    @{cmd_list_r0}     create list
    ...                delete interfaces
    ...                delete security
    ...                commit
    execute config command on device      device=${r0}   command_list=@{cmd_list_r0}   timeout=${250}





Failover the Reduandancy Group 0
    [Documentation]  Failover the redundancy group 0

    ${num}   Get the secondary node info of RG0
    ${response}   execute cli command on device    device=${r1}   command=request chassis cluster failover redundancy-group 0 node ${num}   pattern=(failover for redundancy group 0)
    sleep  30s

Reset the redundancy group 0
    [Documentation]  Reset redundancy group 1

    execute cli command on device    device=${r1}   command=request chassis cluster failover reset redundancy-group 0
    sleep  20s


Reset the redundancy group 1
    [Documentation]  Reset redundancy group 1

    execute cli command on device    device=${r1}   command=request chassis cluster failover reset redundancy-group 1
    sleep  20s

Set the primary node to handle
    [Documentation]  Set the primary node to handle

    sleep   150s
    ${num}    Get the primary node info of RG0
    run keyword if   ${num} == 0    Set Current System Node    device=${r1}   system_node=primary
    run keyword if   ${num} == 1   Set Current System Node    device=${r1}   system_node=slave
    sleep   120s

Set the secondary node to handle
    [Documentation]  Set the primary node to handle

    ${num}    Get the primary node info of RG0
    run keyword if   ${num} == 0    Set Current System Node    device=${r1}   system_node=slave
    run keyword if   ${num} == 1   Set Current System Node    device=${r1}   system_node=primary
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

Get the primary node info of RG1
    [Documentation]  Get the primary node info of RG1

   # set test variable    ${pri_num}   none
    ${response}    execute cli command on device    device=${r1}   command=show chassis cluster status |display xml
    ${status1}   get element text   ${response}     chassis-cluster-status/redundancy-group[2]/device-stats/redundancy-group-status[1]
    ${status2}   get element text   ${response}     chassis-cluster-status/redundancy-group[2]/device-stats/redundancy-group-status[2]
    run keyword if   '${status1}'=='primary'    set test variable   ${pri_num}  0
    run keyword if   '${status2}'=='primary'    set test variable   ${pri_num}  1
    [Return]  ${pri_num}

Failover the Reduandancy Group 1
    [Documentation]  Failover the redundancy group 1

    ${num}   Get the secondary node info of RG1
    ${response}   execute cli command on device    device=${r1}   command=request chassis cluster failover redundancy-group 1 node ${num}
    sleep  30s

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

Get the secondary node info of RG1
    [Documentation]  Get the secondary node info of RG1

   # set test variable  ${node_num}  none
    ${response}    execute cli command on device    device=${r1}   command=show chassis cluster status |display xml
    ${status1}   get element text   ${response}     chassis-cluster-status/redundancy-group[2]/device-stats/redundancy-group-status[1]
    ${status2}   get element text   ${response}     chassis-cluster-status/redundancy-group[2]/device-stats/redundancy-group-status[2]
    run keyword if   '${status1}'=='secondary'     set test variable  ${node_num}   0
    run keyword if    '${status2}'=='secondary'    set test variable  ${node_num}   1
    [Return]  ${node_num}


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

     ${response}    execute shell command on device      device=${client}   command=ls -al /var/tmp/testfilelocal
     ${ls}   ${localsize} =   Should Match Regexp    ${response}    \\S+\\s+\\S+\\s+\\S+\\s+\\S+\\s+(\\d+)\\s+
     #Log to Console    "hbhbhb\n\n\n${localsize}\n\n\nhbhbhb"

     set suite variable      ${filelocalsize}      ${localsize}

     ${response}    execute shell command on device      device=${server}   command=ls -al /var/tmp/testfileremote
     ${ls}   ${remotesize} =   Should Match Regexp    ${response}    \\S+\\s+\\S+\\s+\\S+\\s+\\S+\\s+(\\d+)\\s+
     #Log to Console    "hbhbhb\n\n\n${remotesize}\n\n\nhbhbhb"

     set suite variable      ${fileremotesize}      ${remotesize}

     execute shell command on device      device=${client}   command=rm -rf /var/tmp/folder
     execute shell command on device      device=${client}   command=mkdir /var/tmp/folder
     execute shell command on device      device=${client}   command=cp /var/tmp/testfilelocal /var/tmp/folder/testfilelocal
     sleep  5s
     execute shell command on device      device=${server}   command=rm -rf /var/tmp/folder
     execute shell command on device      device=${server}   command=mkdir /var/tmp/folder
     execute shell command on device      device=${server}   command=cp /var/tmp/testfileremote /var/tmp/folder/testfileremote

     execute shell command on device      device=${client}   command=cp /var/tmp/testfilelocal /var/tmp/testfilelocal2
     execute shell command on device      device=${server}   command=cp /var/tmp/testfileremote /var/tmp/testfileremote2

     sleep  5s


Prepare test file on local and remote for HA
    [Documentation]  Config the twamp server with default config
     execute shell command on device      device=${client}   command=rm -rf /var/tmp/testfilelocal
     sleep  5s
     Save Device Configuration      device=${client}   file=/var/tmp/testfilelocal
     sleep  5s
     execute shell command on device      device=${server}   command=rm -rf /var/tmp/testfileremote
     sleep  5s
     Save Device Configuration      device=${server}   file=/var/tmp/testfileremote
     sleep  5s

     ${response}    execute shell command on device      device=${client}   command=ls -al /var/tmp/testfilelocal
     ${ls}   ${localsize} =   Should Match Regexp    ${response}    \\S+\\s+\\S+\\s+\\S+\\s+\\S+\\s+(\\d+)\\s+
     #Log to Console    "hbhbhb\n\n\n${localsize}\n\n\nhbhbhb"

     set suite variable      ${filelocalsize}      ${localsize}

     ${response}    execute shell command on device      device=${server}   command=ls -al /var/tmp/testfileremote
     ${ls}   ${remotesize} =   Should Match Regexp    ${response}    \\S+\\s+\\S+\\s+\\S+\\s+\\S+\\s+(\\d+)\\s+
     #Log to Console    "hbhbhb\n\n\n${remotesize}\n\n\nhbhbhb"

     set suite variable      ${fileremotesize}      ${remotesize}

     execute shell command on device      device=${client}   command=rm -rf /var/tmp/folder
     execute shell command on device      device=${client}   command=mkdir /var/tmp/folder
     execute shell command on device      device=${client}   command=cp /var/tmp/testfilelocal /var/tmp/folder/testfilelocal
     sleep  5s
     execute shell command on device      device=${server}   command=rm -rf /var/tmp/folder
     execute shell command on device      device=${server}   command=mkdir /var/tmp/folder
     execute shell command on device      device=${server}   command=cp /var/tmp/testfileremote /var/tmp/folder/testfileremote

     execute shell command on device      device=${client}   command=cp /var/tmp/testfilelocal /var/tmp/testfilelocal2
     execute shell command on device      device=${server}   command=cp /var/tmp/testfileremote /var/tmp/testfileremote2

     sleep  5s



Scp file from local to remote
    [Documentation]  Scp file from local to remote
    [Arguments]  ${server_ip}


    ${response}    execute cli command on device      device=${client}   command=scp /var/tmp/testfilelocal regress@${server_ip}:/var/tmp/.   pattern=(no|word)
    ${status}   run keyword and return status   should contain   ${response}     Pass


    run keyword if   '${status}'=='False'    Run Keywords   execute cli command on device      device=${client}   command=yes   pattern=(word)   AND   execute cli command on device      device=${client}   command=MaRtInI


    run keyword if   '${status}'=='True'    execute cli command on device      device=${client}   command=MaRtInI
    sleep  20s

Scp file from remote to local
    [Documentation]  Scp file from remote to local
    [Arguments]  ${server_ip}


    ${response}    execute cli command on device      device=${client}   command=scp regress@${server_ip}:/var/tmp/testfileremote /var/tmp/.   pattern=(no|word)
    ${status}   run keyword and return status   should contain   ${response}     Pass

    run keyword if   '${status}'=='False'    Run Keywords     execute cli command on device      device=${client}   command=yes   pattern=(word)   AND   execute cli command on device      device=${client}   command=MaRtInI


    run keyword if   '${status}'=='True'    execute cli command on device      device=${client}   command=MaRtInI
    sleep  20s


Scp file from remote to local on node1
    [Documentation]  Scp file from remote to local
    [Arguments]  ${server_ip}


    ${response}    execute cli command on device      device=${client}   command=scp regress@${server_ip}:/var/tmp/testfilelocal /var/tmp/.   pattern=(no|word)
    ${status}   run keyword and return status   should contain   ${response}     Pass

    run keyword if   '${status}'=='False'    Run Keywords     execute cli command on device      device=${client}   command=yes   pattern=(word)   AND   execute cli command on device      device=${client}   command=MaRtInI


    run keyword if   '${status}'=='True'    execute cli command on device      device=${client}   command=MaRtInI
    sleep  20s

Scp file from local to remote with source address
    [Documentation]  Scp file from local to remote
    [Arguments]  ${server_ip}  ${source_addr}


    ${response}    execute cli command on device      device=${client}   command=scp /var/tmp/testfilelocal regress@${server_ip}:/var/tmp/. source-address ${source_addr}   pattern=(no|word)
    ${status}   run keyword and return status   should contain   ${response}     Pass


    run keyword if   '${status}'=='False'    Run Keywords   execute cli command on device      device=${client}   command=yes   pattern=(word)   AND   execute cli command on device      device=${client}   command=MaRtInI


    run keyword if   '${status}'=='True'    execute cli command on device      device=${client}   command=MaRtInI
    sleep  20s

Scp file from remote to local with source address
    [Documentation]  Scp file from remote to local
    [Arguments]  ${server_ip}  ${source_addr}


    ${response}    execute cli command on device      device=${client}   command=scp regress@${server_ip}:/var/tmp/testfileremote /var/tmp/. source-address ${source_addr}    pattern=(no|word)
    ${status}   run keyword and return status   should contain   ${response}     Pass

    run keyword if   '${status}'=='False'    Run Keywords     execute cli command on device      device=${client}   command=yes   pattern=(word)   AND   execute cli command on device      device=${client}   command=MaRtInI


    run keyword if   '${status}'=='True'    execute cli command on device      device=${client}   command=MaRtInI
    sleep  20s

Scp file from local to remote in routing instance
    [Documentation]  Scp file from local to remote
    [Arguments]  ${server_ip}


    ${response}    execute cli command on device      device=${client}   command=scp /var/tmp/testfilelocal regress@${server_ip}:/var/tmp/. routing-instance N1   pattern=(no|word)
    ${status}   run keyword and return status   should contain   ${response}     Pass


    run keyword if   '${status}'=='False'    Run Keywords   execute cli command on device      device=${client}   command=yes   pattern=(word)   AND   execute cli command on device      device=${client}   command=MaRtInI


    run keyword if   '${status}'=='True'    execute cli command on device      device=${client}   command=MaRtInI
    sleep  20s

Scp file from remote to local in routing instance
    [Documentation]  Scp file from remote to local
    [Arguments]  ${server_ip}


    ${response}    execute cli command on device      device=${client}   command=scp regress@${server_ip}:/var/tmp/testfileremote /var/tmp/. routing-instance N1   pattern=(no|word)
    ${status}   run keyword and return status   should contain   ${response}     Pass

    run keyword if   '${status}'=='False'    Run Keywords     execute cli command on device      device=${client}   command=yes   pattern=(word)   AND   execute cli command on device      device=${client}   command=MaRtInI


    run keyword if   '${status}'=='True'    execute cli command on device      device=${client}   command=MaRtInI
    sleep  20s

Scp file from local to remote with source address in routing instance
    [Documentation]  Scp file from local to remote
    [Arguments]  ${server_ip}  ${source_addr}


    ${response}    execute cli command on device      device=${client}   command=scp /var/tmp/testfilelocal regress@${server_ip}:/var/tmp/. source-address ${source_addr} routing-instance N1   pattern=(no|word)
    ${status}   run keyword and return status   should contain   ${response}     Pass


    run keyword if   '${status}'=='False'    Run Keywords   execute cli command on device      device=${client}   command=yes   pattern=(word)   AND   execute cli command on device      device=${client}   command=MaRtInI


    run keyword if   '${status}'=='True'    execute cli command on device      device=${client}   command=MaRtInI
    sleep  20s

Scp file from remote to local with source address in routing instance
    [Documentation]  Scp file from remote to local
    [Arguments]  ${server_ip}  ${source_addr}


    ${response}    execute cli command on device      device=${client}   command=scp regress@${server_ip}:/var/tmp/testfileremote /var/tmp/. source-address ${source_addr} routing-instance N1    pattern=(no|word)
    ${status}   run keyword and return status   should contain   ${response}     Pass

    run keyword if   '${status}'=='False'    Run Keywords     execute cli command on device      device=${client}   command=yes   pattern=(word)   AND   execute cli command on device      device=${client}   command=MaRtInI


    run keyword if   '${status}'=='True'    execute cli command on device      device=${client}   command=MaRtInI
    sleep  20s

Scp folder from local to remote
    [Documentation]  Scp file from local to remote
    [Arguments]  ${server_ip}


    ${response}    execute cli command on device      device=${client}   command=scp recursive /var/tmp/folder/ regress@${server_ip}:/var/tmp/.   pattern=(continue connecting|word)
    ${status}   run keyword and return status   should contain   ${response}     fingerprint


    run keyword if   '${status}'=='True'    Run Keywords   execute cli command on device      device=${client}   command=yes   pattern=(word)   AND   execute cli command on device      device=${client}   command=MaRtInI


    run keyword if   '${status}'=='False'    execute cli command on device      device=${client}   command=MaRtInI
    sleep  20s

Scp folder from remote to local
    [Documentation]  Scp file from remote to local
    [Arguments]  ${server_ip}


    ${response}    execute cli command on device      device=${client}   command=scp recursive regress@${server_ip}:/var/tmp/folder/ /var/tmp/.   pattern=(continue connecting|word)
    ${status}   run keyword and return status   should contain   ${response}     fingerprint

    run keyword if   '${status}'=='True'    Run Keywords     execute cli command on device      device=${client}   command=yes   pattern=(word)   AND   execute cli command on device      device=${client}   command=MaRtInI


    run keyword if   '${status}'=='False'    execute cli command on device      device=${client}   command=MaRtInI
    sleep  20s

Scp folder from local to remote in routing instance
    [Documentation]  Scp file from local to remote
    [Arguments]  ${server_ip}


    ${response}    execute cli command on device      device=${client}   command=scp recursive /var/tmp/folder/ regress@${server_ip}:/var/tmp/. routing-instance N1  pattern=(continue connecting|word)
    ${status}   run keyword and return status   should contain   ${response}     fingerprint


    run keyword if   '${status}'=='True'    Run Keywords   execute cli command on device      device=${client}   command=yes   pattern=(word)   AND   execute cli command on device      device=${client}   command=MaRtInI


    run keyword if   '${status}'=='False'    execute cli command on device      device=${client}   command=MaRtInI
    sleep  20s

Scp folder from remote to local in routing instance
    [Documentation]  Scp file from remote to local
    [Arguments]  ${server_ip}


    ${response}    execute cli command on device      device=${client}   command=scp recursive regress@${server_ip}:/var/tmp/folder/ /var/tmp/. routing-instance N1  pattern=(continue connecting|word)
    ${status}   run keyword and return status   should contain   ${response}     fingerprint

    run keyword if   '${status}'=='True'    Run Keywords     execute cli command on device      device=${client}   command=yes   pattern=(word)   AND   execute cli command on device      device=${client}   command=MaRtInI


    run keyword if   '${status}'=='False'    execute cli command on device      device=${client}   command=MaRtInI
    sleep  20s

Check copied file size
    [Documentation]  check scp file correct
    [Arguments]  ${device}  ${filename}  ${size}


    ${response}    execute shell command on device      device=${device}   command=ls -al /var/tmp/${filename}
    ${ls}   ${filesize} =   Should Match Regexp    ${response}    \\S+\\s+\\S+\\s+\\S+\\s+\\S+\\s+(\\d+)\\s+
    #Log to Console    "hbhbhb\n\n\n${filesize}\n\n\nhbhbhb"

    Should Be Equal    ${size}    ${filesize}
    #Log to Console    "hbhbhb\n\n\nEqual\n\n\nhbhbhb"
    sleep  2s

Delete copied files
    [Documentation]  delete copied files

     execute shell command on device      device=${client}   command=rm -rf /var/tmp/testfileremote
     sleep  5s
     execute shell command on device      device=${server}   command=rm -rf /var/tmp/testfilelocal
     sleep  5s

     ${response}    execute shell command on device      device=${client}   command=ls -al /var/tmp/testfileremote
     should contain     ${response}     No such
     ${response}    execute shell command on device      device=${server}   command=ls -al /var/tmp/testfilelocal
     should contain     ${response}     No such

Delete copied folers
    [Documentation]  delete copied files

     execute shell command on device      device=${client}   command=rm -rf /var/tmp/folder/testfileremote
     sleep  5s
     execute shell command on device      device=${server}   command=rm -rf /var/tmp/folder/testfilelocal
     sleep  5s

     ${response}    execute shell command on device      device=${client}   command=ls -al /var/tmp/folder/testfileremote
     should contain     ${response}     No such
     ${response}    execute shell command on device      device=${server}   command=ls -al /var/tmp/folder/testfilelocal
     should contain     ${response}     No such

Delete test files
    [Documentation]  delete copied test files

     execute shell command on device      device=${server}   command=rm -rf /var/tmp/testfileremote
     execute shell command on device      device=${server}   command=rm -rf /var/tmp/testfileremote2
     execute shell command on device      device=${server}   command=rm -rf /var/tmp/folder
     sleep  5s
     execute shell command on device      device=${client}   command=rm -rf /var/tmp/testfilelocal
     execute shell command on device      device=${client}   command=rm -rf /var/tmp/testfilelocal2
     execute shell command on device      device=${client}   command=rm -rf /var/tmp/folder
     sleep  5s

Scp interactive test
    [Documentation]  Scp interactive test

    execute shell command on device      device=${client}   command=rm -rf ~regress/.ssh/known_hosts
    sleep  10s

    ${response}    execute cli command on device      device=${client}   command=scp regress@${tv['uv-r1_r0-ip']}:/var/tmp/testfileremote /var/tmp/.    pattern=(no)
    ${response}    execute cli command on device      device=${client}   command=xx    pattern=(Please type)
    ${response}    execute cli command on device      device=${client}   command=yes    pattern=(word)
    ${response}    execute cli command on device      device=${client}   command=xx    pattern=(word)   timeout=${150}
    ${response}    execute cli command on device      device=${client}   command=xx    pattern=(word)   timeout=${150}
    ${response}    execute cli command on device      device=${client}   command=xx    pattern=(Too many password failures)   timeout=${150}
    #sleep  20s


Config VR routing instance
    [Documentation]  Config VR routing instance

    @{cmd_list_r0}     create list
    ...                set routing-instances N1 instance-type virtual-router
    ...                set routing-instances N1 interface ${tv['r0__r0r1__pic']}.0
    ...                set routing-instances N1 interface lo0.0
    ...                set routing-instances N1 routing-options static route ${tv['uv-r1_r0-nm-lo']} next-hop ${tv['uv-r1_r0-ip']}
    ...                set routing-instances N1 routing-options rib N1.inet6.0 static route ${tv['uv-r1_r0-nm6-lo']} next-hop ${tv['uv-r1_r0-ip6']}
    ...                commit
    execute config command on device      device=${r0}   command_list=@{cmd_list_r0}   timeout=${150}


    sleep   20s
    ${response1}   execute cli command on device    device=${client}   command=ping ${target_addr} routing-instance N1 count 10
    should not contain     ${response1}     100% packet loss
    ${response2}   execute cli command on device    device=${client}   command=ping ${tv['uv-r1_r0-ip6']} routing-instance N1 count 30
    should not contain     ${response2}     100% packet loss
    ${response2}   execute cli command on device    device=${client}   command=ping ${tv['uv-r1_r0-ip6-lo']} source ${tv['uv-r0_r1-ip6-lo']} routing-instance N1 count 30
    should not contain     ${response2}     100% packet loss

Delete VR routing instance
    [Documentation]  Config VR routing instance

    @{cmd_list_r0}     create list
    ...                delete routing-instances N1
    ...                commit
    execute config command on device      device=${r0}   command_list=@{cmd_list_r0}   timeout=${150}


    sleep   20s
    ${response1}   execute cli command on device    device=${client}   command=ping ${target_addr} count 10
    should not contain     ${response1}     100% packet loss
    ${response2}   execute cli command on device    device=${client}   command=ping ${tv['uv-r1_r0-ip6']} count 10
    should not contain     ${response2}     100% packet loss
    ${response2}   execute cli command on device    device=${client}   command=ping ${tv['uv-r1_r0-ip6-lo']} source ${tv['uv-r0_r1-ip6-lo']} count 10
    should not contain     ${response2}     100% packet loss



