Documentation                       RLI36300 scp support on Junos CLI with src-addr and vr options
...             Author             : Ai Liu
...             Date               : 07/25/2017
...             JTMS TEST PLAN     : http://systest.juniper.net/feature_testplan/45429
...             RLI                : 36300
...             MIN RELEASE        : 15.1
...             MAIN FEATURE       : scp CLI
...             Platform Supported : SRX300, SRX320, SRX340, SRX345, SRX550m, SRX1500
...             CUSTOMER           : Moto


*** Settings ***
Resource   jnpr/toby/Master.robot
Resource   test_util.robot
Suite Setup      Run Keywords
...     Initialize the test environment of Topology with two nodes
...     Check all the devices on Flow Mode
...     Init the Configurations on two nodes in Flow Mode
...     Prepare test file on local and remote
#Suite Teardown   Cleanup toby configuration files on device    @{dh_list}
Test Teardown   Run Keywords
...    Delete copied files
Suite Teardown   Run Keywords
...    Delete test files


*** Variables ***



*** Test Cases ***
SCP_TC_1
    [Documentation]
    ...     Tc5.1-1  in default routing instance，scp file from local to remote
    ...     Tc5.1-2  in default routing instance，scp file from remote to local

    [Tags]  scp


    Scp file from local to remote   server_ip=${tv['uv-r1_r0-ip']}
    Check copied file size   device=${server}  filename=testfilelocal  size=${filelocalsize}

    sleep   5s
    Scp file from remote to local   server_ip=${tv['uv-r1_r0-ip']}
    Check copied file size   device=${client}  filename=testfileremote  size=${fileremotesize}
    sleep   5s

SCP_TC_2
    [Documentation]
    ...     Tc5.1-3  in default routing instance，scp file from local to remote with source-address
    ...     Tc5.1-4  in default routing instance，scp file from remote to local with source-address

    [Tags]  scp with source address


    Scp file from local to remote with source address  server_ip=${tv['uv-r1_r0-ip-lo']}  source_addr=${tv['uv-r0_r1-ip-lo']}
    Check copied file size   device=${server}  filename=testfilelocal  size=${filelocalsize}

    sleep   5s
    Scp file from remote to local with source address  server_ip=${tv['uv-r1_r0-ip-lo']}  source_addr=${tv['uv-r0_r1-ip-lo']}
    Check copied file size   device=${client}  filename=testfileremote  size=${fileremotesize}
    sleep   5s

SCP_TC_3
    [Documentation]
    ...     Tc5.1-9  in default routing instance，scp file from local to remote for ipv6
    ...     Tc5.1-9  in default routing instance，scp file from remote to local for ipv6

    [Tags]  scp


    Scp file from local to remote   server_ip=[${tv['uv-r1_r0-ip6']}]
    Check copied file size   device=${server}  filename=testfilelocal  size=${filelocalsize}

    sleep   5s
    Scp file from remote to local   server_ip=[${tv['uv-r1_r0-ip6']}]
    Check copied file size   device=${client}  filename=testfileremote  size=${fileremotesize}
    sleep   5s

SCP_TC_4
    [Documentation]
    ...     Tc5.1-9  in default routing instance，scp file from local to remote with source-address for ipv6
    ...     Tc5.1-9  in default routing instance，scp file from remote to local with source-address for ipv6

    [Tags]  scp with source address

    #sleep   50000000s
    Scp file from local to remote with source address  server_ip=[${tv['uv-r1_r0-ip6-lo']}]  source_addr=${tv['uv-r0_r1-ip6-lo']}
    Check copied file size   device=${server}  filename=testfilelocal  size=${filelocalsize}

    sleep   5s
    Scp file from remote to local with source address  server_ip=[${tv['uv-r1_r0-ip6-lo']}]  source_addr=${tv['uv-r0_r1-ip6-lo']}
    Check copied file size   device=${client}  filename=testfileremote  size=${fileremotesize}
    sleep   5s

SCP_TC_5
    [Documentation]
    ...     Tc5.1-5  in default routing instance，scp file from local to remote in routing instance
    ...     Tc5.1-6  in default routing instance，scp file from remote to local in routing instance
    [Tags]  scp with in routing instance


    Scp file from local to remote in routing instance   server_ip=${tv['uv-r1_r0-ip2']}
    Check copied file size   device=${server}  filename=testfilelocal  size=${filelocalsize}
    sleep   5s
    Scp file from remote to local in routing instance   server_ip=${tv['uv-r1_r0-ip2']}
    Check copied file size   device=${client}  filename=testfileremote  size=${fileremotesize}
    sleep   5s


SCP_TC_6
    [Documentation]
    ...     Tc5.1-7  in default routing instance，scp file from local to remote with source-address in routing instance
    ...     Tc5.1-8  in default routing instance，scp file from remote to local with source-address in routing instance
    [Tags]  scp with in routing instance



    Scp file from local to remote with source address in routing instance   server_ip=${tv['uv-r1_r0-ip-lo']}  source_addr=${tv['uv-r0_r1-ip-lo2']}
    Check copied file size   device=${server}  filename=testfilelocal  size=${filelocalsize}
    sleep   5s

    Scp file from remote to local with source address in routing instance   server_ip=${tv['uv-r1_r0-ip-lo']}  source_addr=${tv['uv-r0_r1-ip-lo2']}
    Check copied file size   device=${client}  filename=testfileremote  size=${fileremotesize}
    sleep   5s

SCP_TC_7
    [Documentation]
    ...     Tc5.1-5  in default routing instance，scp file from local to remote in routing instance for ipv6
    ...     Tc5.1-6  in default routing instance，scp file from remote to local in routing instance for ipv6
    [Tags]  scp with in routing instance




    Scp file from local to remote in routing instance  server_ip=[${tv['uv-r1_r0-ip6-lo']}]
    Check copied file size   device=${server}  filename=testfilelocal  size=${filelocalsize}

    sleep   5s
    Scp file from remote to local in routing instance  server_ip=[${tv['uv-r1_r0-ip6-lo']}]
    Check copied file size   device=${client}  filename=testfileremote  size=${fileremotesize}

    sleep   5s

SCP_TC_8
    [Documentation]
    ...     Tc5.1-7  in default routing instance，scp file from local to remote with source-address in routing instance for ipv6
    ...     Tc5.1-8  in default routing instance，scp file from remote to local with source-address in routing instance for ipv6
    [Tags]  scp with in routing instance



    Scp file from local to remote with source address in routing instance  server_ip=[${tv['uv-r1_r0-ip6-lo']}]  source_addr=${tv['uv-r0_r1-ip6-lo2']}
    Check copied file size   device=${server}  filename=testfilelocal  size=${filelocalsize}

    sleep   5s
    Scp file from remote to local with source address in routing instance  server_ip=[${tv['uv-r1_r0-ip6-lo']}]  source_addr=${tv['uv-r0_r1-ip6-lo2']}
    Check copied file size   device=${client}  filename=testfileremote  size=${fileremotesize}
    sleep   5s



SCP_TC_9
    [Documentation]
    ...     Tc5.1-10  scp authenticity test
    [Tags]  scp command interactive test
    Scp interactive test


SCP_TC_10
    [Documentation]
    ...     Tc5.1-11  scp with recursive option
    [Tags]  scp with recursive option

    Scp folder from local to remote   server_ip=${tv['uv-r1_r0-ip']}
    Check copied file size   device=${server}  filename=folder/testfilelocal  size=${filelocalsize}

    sleep   5s
    Scp folder from remote to local   server_ip=${tv['uv-r1_r0-ip']}
    Check copied file size   device=${client}  filename=folder/testfileremote  size=${fileremotesize}
    sleep   5s
    Delete copied folers

SCP_TC_11
    [Documentation]
    ...     Tc5.1-12  multiple scp test
    [Tags]  multiple scp test

    Scp file from local to remote   server_ip=${tv['uv-r1_r0-ip']}
    Check copied file size   device=${server}  filename=testfilelocal  size=${filelocalsize}
    Scp folder from local to remote in routing instance   server_ip=${tv['uv-r1_r0-ip2']}
    Check copied file size   device=${server}  filename=folder/testfilelocal  size=${filelocalsize}


# TWAMP_Server_Flow_Mode_TC_2
#     [Documentation]
#     ...     Tc5.1-4  Verify the functioning of maximum-sessions
#     ...     Tc5.1-5  Verify the functioning of maximum sessions per connection
#     ...     Tc6-3  Verify TWAMP Scaling with default Max Sessions
#     ...     Tc6-4  Verify TWAMP Scaling with default Max sessions per connection.
#     ...     Tc6-5  Verify TWAMP Scaling for Baselined numbers


#     [Tags]  TWAMP_Server  Flow_Mode

#     #check maximum-connections
#     Configure Twamp Client for sessions default scaling
#     Config the twamp server with basic config  client_network=${tv['uv-r0_r1-nm']}

#     Start twamp client connction
#     Verify Twamp Server Total Session Count  session_cnt=${64}
#     Verify Twamp Server Sesson Count Per Connection  sess_cnt_conn=64
#     Stop twamp client connction
#     Congiure Twamp Server Maximum Sessions  session_cnt=${63}

#     Start twamp client connction
#     Verify Twamp Server the connection and session not exist
#     Delete one session under the connection   session=t64
#     Start twamp client connction
#     Verify Twamp Server Total Session Count  session_cnt=${63}
#     Stop twamp client connction
#     Congiure Twamp Server Maximum Sessions Per Connecton   session_cnt_percon=62
#     Start twamp client connction
#     Verify Twamp Server the connection and session not exist
#     Delete one session under the connection   session=t63
#     Start twamp client connction
#     Verify Twamp Server Total Session Count  session_cnt=${62}
#     Stop twamp client connction


# TWAMP_Server_Flow_Mode_TC_3
#     [Documentation]
#     ...     Tc5.1-6  TWAMP server should abort test sessions which timeout.
#     ...     Tc5.1-7  TWAMP session should be aborted when server issues clear connection
#     ...     Tc5.1-8  TWAMP inactivity timeout when set to 0 should never terminate connection

#     [Tags]  TWAMP_Server  Flow_Mode

#     #Check the server-inactivity-timeout function
#     Config the twamp client with basic config  connection_name=${tv['uv-connection-name']}   session_name=${tv['uv-session-name']}  target_addr=${tv['uv-r1_r0-ip']}  probe_count=${tv['uv-probes-count']}
#     Config the twamp server with basic config  client_network=${tv['uv-r0_r1-nm']}
#     Configure Twamp Server inactivity timeout  timeout=${tv['uv-inact-timeout']}

#     Start twamp client connction
#     Initialize Verification Engine    151_RLI35194_SRX_Twamp_Server.verify.yaml
#     Verify Twamp Server Control Connection  client_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}  server_addr=${tv['uv-r1_r0-ip']}   server_port=862   session_cnt=1
#     Verify Twamp Server Test Session    sender_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Control Connection    connection_name=${tv['uv-connection-name']}   client_addr=${tv['uv-r0_r1-ip']}   server_addr=${tv['uv-r1_r0-ip']}   server_port=862
#     Verify Twamp Client Test Session    connection_name=${tv['uv-connection-name']}    session_name=${tv['uv-session-name']}   sender_addr=${tv['uv-r0_r1-ip']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Test Probes Basic Info    owner=${tv['uv-connection-name']}   test_name=${tv['uv-session-name']}  srv_addr=${tv['uv-r1_r0-ip']}   srv_port=862   client_addr=${tv['uv-r0_r1-ip']}  reflct_addr=${tv['uv-r1_r0-ip']}  sender_addr=${tv['uv-r0_r1-ip']}   test_size=${tv['uv-probes-count']}
#     Verify Twamp Client Test Probes Single Results   rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes Current Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes One Sample Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Stop twamp client connction
#     Verify Twamp Server the connection and session not exist
#     Verify Twamp Client Control Connection is Stopped
#     Verify Twamp Client Test Session is Stopped
#     sleep  10s
#     Configure Twamp Server inactivity timeout  timeout=0
#     Start twamp client connction
#     Verify Twamp Server Control Connection  client_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}  server_addr=${tv['uv-r1_r0-ip']}   server_port=862   session_cnt=1
#     Verify Twamp Server Test Session    sender_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Control Connection    connection_name=${tv['uv-connection-name']}   client_addr=${tv['uv-r0_r1-ip']}   server_addr=${tv['uv-r1_r0-ip']}   server_port=862
#     Verify Twamp Client Test Session    connection_name=${tv['uv-connection-name']}    session_name=${tv['uv-session-name']}   sender_addr=${tv['uv-r0_r1-ip']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Test Probes Basic Info    owner=${tv['uv-connection-name']}   test_name=${tv['uv-session-name']}  srv_addr=${tv['uv-r1_r0-ip']}   srv_port=862   client_addr=${tv['uv-r0_r1-ip']}  reflct_addr=${tv['uv-r1_r0-ip']}  sender_addr=${tv['uv-r0_r1-ip']}   test_size=${tv['uv-probes-count']}
#     Verify Twamp Client Test Probes Single Results   rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes Current Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes One Sample Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Clear Twamp Server Connction All
#     Verify Twamp Server the connection and session not exist
#     Verify Twamp Client Control Connection is Stopped
#     Verify Twamp Client Test Session is Stopped


#     #check the clear service rpm twamp server connection function
#     Start twamp client connction
#     Initialize Verification Engine    151_RLI35194_SRX_Twamp_Server.verify.yaml
#     Verify Twamp Server Control Connection  client_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}  server_addr=${tv['uv-r1_r0-ip']}   server_port=862   session_cnt=1
#     Verify Twamp Server Test Session    sender_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Control Connection    connection_name=${tv['uv-connection-name']}   client_addr=${tv['uv-r0_r1-ip']}   server_addr=${tv['uv-r1_r0-ip']}   server_port=862
#     Verify Twamp Client Test Session    connection_name=${tv['uv-connection-name']}    session_name=${tv['uv-session-name']}   sender_addr=${tv['uv-r0_r1-ip']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Test Probes Basic Info    owner=${tv['uv-connection-name']}   test_name=${tv['uv-session-name']}  srv_addr=${tv['uv-r1_r0-ip']}   srv_port=862   client_addr=${tv['uv-r0_r1-ip']}  reflct_addr=${tv['uv-r1_r0-ip']}  sender_addr=${tv['uv-r0_r1-ip']}   test_size=${tv['uv-probes-count']}
#     Verify Twamp Client Test Probes Single Results   rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes Current Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes One Sample Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Clear Twamp Server Connction All
#     Verify Twamp Server the connection and session not exist
#     Verify Twamp Client Control Connection is Stopped
#     Verify Twamp Client Test Session is Stopped
#     Start twamp client connction
#     ${conn_id}   Get Connection ID on Twamp Server
#     Clear Twamp Server Connection ID   ID=${conn_id}
#     Verify Twamp Server the connection and session not exist
#     Verify Twamp Client Control Connection is Stopped
#     Verify Twamp Client Test Session is Stopped


# TWAMP_Server_Flow_Mode_TC_4
#     [Documentation]
#     ...     Tc5.1-11  Verify the functioning of routing-instance-list
#     ...     Tc5.1-12  TWAMP session packets with Filter
#     ...     Tc5.1-13  TWAMP sessions should not be established if client is removed from allowed client list.

#     [Tags]  TWAMP_Server  Flow_Mode

#     #Check Twamp sessions can't establish if removed from client
#     Config the twamp client with basic config  connection_name=${tv['uv-connection-name']}   session_name=${tv['uv-session-name']}  target_addr=${tv['uv-r1_r0-ip']}  probe_count=${tv['uv-probes-count']}
#     Config the twamp server with basic config  client_network=${tv['uv-r0_r1-nm']}
#     Start twamp client connction
#     Initialize Verification Engine    151_RLI35194_SRX_Twamp_Server.verify.yaml
#     Verify Twamp Server Control Connection  client_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}  server_addr=${tv['uv-r1_r0-ip']}   server_port=862   session_cnt=1
#     Verify Twamp Server Test Session    sender_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Control Connection    connection_name=${tv['uv-connection-name']}   client_addr=${tv['uv-r0_r1-ip']}   server_addr=${tv['uv-r1_r0-ip']}   server_port=862
#     Verify Twamp Client Test Session    connection_name=${tv['uv-connection-name']}    session_name=${tv['uv-session-name']}   sender_addr=${tv['uv-r0_r1-ip']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Test Probes Basic Info    owner=${tv['uv-connection-name']}   test_name=${tv['uv-session-name']}  srv_addr=${tv['uv-r1_r0-ip']}   srv_port=862   client_addr=${tv['uv-r0_r1-ip']}  reflct_addr=${tv['uv-r1_r0-ip']}  sender_addr=${tv['uv-r0_r1-ip']}   test_size=${tv['uv-probes-count']}
#     Verify Twamp Client Test Probes Single Results   rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes Current Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes One Sample Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Stop twamp client connction
#     Remove the twamp Client from Client list   client_nm=${tv['uv-r0_r1-nm']}
#     Start twamp client connction
#     Verify Twamp Server the connection and session not exist
#     Config the twamp server with basic config  client_network=${tv['uv-r0_r1-nm']}
#     Start twamp client connction
#     Verify Twamp Server Control Connection  client_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}  server_addr=${tv['uv-r1_r0-ip']}   server_port=862   session_cnt=1
#     Verify Twamp Server Test Session    sender_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Control Connection    connection_name=${tv['uv-connection-name']}   client_addr=${tv['uv-r0_r1-ip']}   server_addr=${tv['uv-r1_r0-ip']}   server_port=862
#     Verify Twamp Client Test Session    connection_name=${tv['uv-connection-name']}    session_name=${tv['uv-session-name']}   sender_addr=${tv['uv-r0_r1-ip']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Test Probes Basic Info    owner=${tv['uv-connection-name']}   test_name=${tv['uv-session-name']}  srv_addr=${tv['uv-r1_r0-ip']}   srv_port=862   client_addr=${tv['uv-r0_r1-ip']}  reflct_addr=${tv['uv-r1_r0-ip']}  sender_addr=${tv['uv-r0_r1-ip']}   test_size=${tv['uv-probes-count']}
#     Verify Twamp Client Test Probes Single Results   rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes Current Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes One Sample Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Stop twamp client connction

#     #Check the session work with filter
#     Clear Twamp Server Connction All
#     Configure Firewall Filter to Discard Twamp Packets  client_ip=${tv['uv-r0_r1-ip']}  interface=${tv['r1__r1r0__pic']}
#     Start twamp client connction
#     stop twamp client connction
#     start twamp client connction
#     Verify Twamp Server the connection and session not exist
#     Configure Firewall Filter to Permit the Twamp Packets  client_ip=${tv['uv-r0_r1-ip']}  interface=${tv['r1__r1r0__pic']}
#     Start twamp client connction
#     Verify Twamp Server Control Connection  client_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}  server_addr=${tv['uv-r1_r0-ip']}   server_port=862   session_cnt=1
#     Verify Twamp Server Test Session    sender_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Control Connection    connection_name=${tv['uv-connection-name']}   client_addr=${tv['uv-r0_r1-ip']}   server_addr=${tv['uv-r1_r0-ip']}   server_port=862
#     Verify Twamp Client Test Session    connection_name=${tv['uv-connection-name']}    session_name=${tv['uv-session-name']}   sender_addr=${tv['uv-r0_r1-ip']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Test Probes Basic Info    owner=${tv['uv-connection-name']}   test_name=${tv['uv-session-name']}  srv_addr=${tv['uv-r1_r0-ip']}   srv_port=862   client_addr=${tv['uv-r0_r1-ip']}  reflct_addr=${tv['uv-r1_r0-ip']}  sender_addr=${tv['uv-r0_r1-ip']}   test_size=${tv['uv-probes-count']}
#     Verify Twamp Client Test Probes Single Results   rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes Current Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes One Sample Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Stop twamp client connction

#     #Check the functioning of routing-instance-list

#     Configure Routing Instance on Twamp Server  instance_name=${tv['uv-routing-instance']}    interface=${tv['r1__r1r0__pic']}  client_ip=${tv['uv-r0_r1-ip']}
#     Configure Routing Instance Options In TWAMP Server  instance=${tv['uv-routing-instance']}   port=${tv['uv-port']}
#     Configure Twamp Client Connection Destination Port   connection_name=${tv['uv-connection-name']}   port=${tv['uv-port']}

#     sleep  10s
#     Start twamp client connction
#     Verify Twamp Server Control Connection  client_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}  server_addr=${tv['uv-r1_r0-ip']}   server_port=${tv['uv-port']}   session_cnt=1
#     Verify Twamp Server Test Session    sender_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Control Connection    connection_name=${tv['uv-connection-name']}   client_addr=${tv['uv-r0_r1-ip']}   server_addr=${tv['uv-r1_r0-ip']}   server_port=${tv['uv-port']}
#     Verify Twamp Client Test Session    connection_name=${tv['uv-connection-name']}    session_name=${tv['uv-session-name']}   sender_addr=${tv['uv-r0_r1-ip']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Test Probes Basic Info    owner=${tv['uv-connection-name']}   test_name=${tv['uv-session-name']}  srv_addr=${tv['uv-r1_r0-ip']}   srv_port=${tv['uv-port']}   client_addr=${tv['uv-r0_r1-ip']}  reflct_addr=${tv['uv-r1_r0-ip']}  sender_addr=${tv['uv-r0_r1-ip']}   test_size=${tv['uv-probes-count']}
#     Verify Twamp Client Test Probes Single Results   rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes Current Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes One Sample Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Stop twamp client connction
#     Restore the routing instance to default


# TWAMP_Server_Flow_Mode_TC_5
#     [Documentation]
#     ...     Tc5.3-1  Verify after RMOPD restart
#     ...     Tc5.3-2  Verify restrat chassis-control in client machine
#     ...     Tc5.3-3  Deactivate/activate interfaces
#     ...     Tc5.3-4  Verify rebooting the whole system in client machine where twamp requestor configured
#     ...     Tc5.3-5  Deactivate/activate services for RPM/TWAMP

#     [Tags]  TWAMP_Server  Flow_Mode  Negative

#     Config the twamp client with basic config  connection_name=${tv['uv-connection-name']}   session_name=${tv['uv-session-name']}  target_addr=${tv['uv-r1_r0-ip']}  probe_count=${tv['uv-probes-count']}
#     Config the twamp server with basic config  client_network=${tv['uv-r0_r1-nm']}

#     #Check RMOPD restart
#     Start twamp client connction
#     Initialize Verification Engine    151_RLI35194_SRX_Twamp_Server.verify.yaml
#     Verify Twamp Server Control Connection  client_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}  server_addr=${tv['uv-r1_r0-ip']}   server_port=862   session_cnt=1
#     Verify Twamp Server Test Session    sender_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Control Connection    connection_name=${tv['uv-connection-name']}   client_addr=${tv['uv-r0_r1-ip']}   server_addr=${tv['uv-r1_r0-ip']}   server_port=862
#     Verify Twamp Client Test Session    connection_name=${tv['uv-connection-name']}    session_name=${tv['uv-session-name']}   sender_addr=${tv['uv-r0_r1-ip']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Test Probes Basic Info    owner=${tv['uv-connection-name']}   test_name=${tv['uv-session-name']}  srv_addr=${tv['uv-r1_r0-ip']}   srv_port=862   client_addr=${tv['uv-r0_r1-ip']}  reflct_addr=${tv['uv-r1_r0-ip']}  sender_addr=${tv['uv-r0_r1-ip']}   test_size=${tv['uv-probes-count']}
#     Verify Twamp Client Test Probes Single Results   rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes Current Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes One Sample Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Restart RMOPD Process
#     Verify Twamp Server the connection and session not exist
#     Verify Twamp Client Control Connection is Stopped
#     Verify Twamp Client Test Session is Stopped
#     Start twamp client connction
#     Verify Twamp Server Control Connection  client_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}  server_addr=${tv['uv-r1_r0-ip']}   server_port=862  session_cnt=1
#     Verify Twamp Server Test Session    sender_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Control Connection    connection_name=${tv['uv-connection-name']}   client_addr=${tv['uv-r0_r1-ip']}   server_addr=${tv['uv-r1_r0-ip']}   server_port=862
#     Verify Twamp Client Test Session    connection_name=${tv['uv-connection-name']}    session_name=${tv['uv-session-name']}   sender_addr=${tv['uv-r0_r1-ip']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Test Probes Basic Info    owner=${tv['uv-connection-name']}   test_name=${tv['uv-session-name']}  srv_addr=${tv['uv-r1_r0-ip']}   srv_port=862   client_addr=${tv['uv-r0_r1-ip']}  reflct_addr=${tv['uv-r1_r0-ip']}  sender_addr=${tv['uv-r0_r1-ip']}   test_size=${tv['uv-probes-count']}
#     Verify Twamp Client Test Probes Single Results   rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes Current Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes One Sample Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Clear Twamp Server Connction All

#     #Check restart chassis-control
#     Start twamp client connction
#     Verify Twamp Server Control Connection  client_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}  server_addr=${tv['uv-r1_r0-ip']}   server_port=862   session_cnt=1
#     Verify Twamp Server Test Session    sender_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Control Connection    connection_name=${tv['uv-connection-name']}   client_addr=${tv['uv-r0_r1-ip']}   server_addr=${tv['uv-r1_r0-ip']}   server_port=862
#     Verify Twamp Client Test Session    connection_name=${tv['uv-connection-name']}    session_name=${tv['uv-session-name']}   sender_addr=${tv['uv-r0_r1-ip']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Test Probes Basic Info    owner=${tv['uv-connection-name']}   test_name=${tv['uv-session-name']}  srv_addr=${tv['uv-r1_r0-ip']}   srv_port=862   client_addr=${tv['uv-r0_r1-ip']}  reflct_addr=${tv['uv-r1_r0-ip']}  sender_addr=${tv['uv-r0_r1-ip']}   test_size=${tv['uv-probes-count']}
#     Verify Twamp Client Test Probes Single Results   rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes Current Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes One Sample Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Restart Chassis Control
#     Verify Twamp Server the connection and session not exist
#     stop twamp client connction
#     Start twamp client connction
#     Verify Twamp Server Control Connection  client_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}  server_addr=${tv['uv-r1_r0-ip']}   server_port=862  session_cnt=1
#     Verify Twamp Server Test Session    sender_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Control Connection    connection_name=${tv['uv-connection-name']}   client_addr=${tv['uv-r0_r1-ip']}   server_addr=${tv['uv-r1_r0-ip']}   server_port=862
#     Verify Twamp Client Test Session    connection_name=${tv['uv-connection-name']}    session_name=${tv['uv-session-name']}   sender_addr=${tv['uv-r0_r1-ip']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Test Probes Basic Info    owner=${tv['uv-connection-name']}   test_name=${tv['uv-session-name']}  srv_addr=${tv['uv-r1_r0-ip']}   srv_port=862   client_addr=${tv['uv-r0_r1-ip']}  reflct_addr=${tv['uv-r1_r0-ip']}  sender_addr=${tv['uv-r0_r1-ip']}   test_size=${tv['uv-probes-count']}
#     Verify Twamp Client Test Probes Single Results   rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes Current Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes One Sample Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Clear Twamp Server Connction All

#     ##Check Deactivate and Activate Interface
#     Start twamp client connction
#     Verify Twamp Server Control Connection  client_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}  server_addr=${tv['uv-r1_r0-ip']}   server_port=862   session_cnt=1
#     Verify Twamp Server Test Session    sender_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Control Connection    connection_name=${tv['uv-connection-name']}   client_addr=${tv['uv-r0_r1-ip']}   server_addr=${tv['uv-r1_r0-ip']}   server_port=862
#     Verify Twamp Client Test Session    connection_name=${tv['uv-connection-name']}    session_name=${tv['uv-session-name']}   sender_addr=${tv['uv-r0_r1-ip']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Test Probes Basic Info    owner=${tv['uv-connection-name']}   test_name=${tv['uv-session-name']}  srv_addr=${tv['uv-r1_r0-ip']}   srv_port=862   client_addr=${tv['uv-r0_r1-ip']}  reflct_addr=${tv['uv-r1_r0-ip']}  sender_addr=${tv['uv-r0_r1-ip']}   test_size=${tv['uv-probes-count']}
#     Verify Twamp Client Test Probes Single Results   rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes Current Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes One Sample Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Disable Twamp Server Interface  interface=${tv['r1__r1r0__pic']}
#     Verify Twamp Server the connection and session not exist
#     Enable Twamp Server Interface  interface=${tv['r1__r1r0__pic']}
#     Start twamp client connction
#     Verify Twamp Server Control Connection  client_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}  server_addr=${tv['uv-r1_r0-ip']}   server_port=862   session_cnt=1
#     Verify Twamp Server Test Session    sender_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Control Connection    connection_name=${tv['uv-connection-name']}   client_addr=${tv['uv-r0_r1-ip']}   server_addr=${tv['uv-r1_r0-ip']}   server_port=862
#     Verify Twamp Client Test Session    connection_name=${tv['uv-connection-name']}    session_name=${tv['uv-session-name']}   sender_addr=${tv['uv-r0_r1-ip']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Test Probes Basic Info    owner=${tv['uv-connection-name']}   test_name=${tv['uv-session-name']}  srv_addr=${tv['uv-r1_r0-ip']}   srv_port=862   client_addr=${tv['uv-r0_r1-ip']}  reflct_addr=${tv['uv-r1_r0-ip']}  sender_addr=${tv['uv-r0_r1-ip']}   test_size=${tv['uv-probes-count']}
#     Verify Twamp Client Test Probes Single Results   rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes Current Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes One Sample Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Clear Twamp Server Connction All

#     #Check deactivate and activate RPM serveice
#     Start twamp client connction
#     Verify Twamp Server Control Connection  client_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}  server_addr=${tv['uv-r1_r0-ip']}   server_port=862   session_cnt=1
#     Verify Twamp Server Test Session    sender_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Control Connection    connection_name=${tv['uv-connection-name']}   client_addr=${tv['uv-r0_r1-ip']}   server_addr=${tv['uv-r1_r0-ip']}   server_port=862
#     Verify Twamp Client Test Session    connection_name=${tv['uv-connection-name']}    session_name=${tv['uv-session-name']}   sender_addr=${tv['uv-r0_r1-ip']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Test Probes Basic Info    owner=${tv['uv-connection-name']}   test_name=${tv['uv-session-name']}  srv_addr=${tv['uv-r1_r0-ip']}   srv_port=862   client_addr=${tv['uv-r0_r1-ip']}  reflct_addr=${tv['uv-r1_r0-ip']}  sender_addr=${tv['uv-r0_r1-ip']}   test_size=${tv['uv-probes-count']}
#     Verify Twamp Client Test Probes Single Results   rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes Current Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes One Sample Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Deactivate RPM Service Process
#     Verify Twamp Server the connection and session not exist
#     Activate RPM Service Process
#     Start twamp client connction
#     Verify Twamp Server Control Connection  client_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}  server_addr=${tv['uv-r1_r0-ip']}   server_port=862   session_cnt=1
#     Verify Twamp Server Test Session    sender_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Control Connection    connection_name=${tv['uv-connection-name']}   client_addr=${tv['uv-r0_r1-ip']}   server_addr=${tv['uv-r1_r0-ip']}   server_port=862
#     Verify Twamp Client Test Session    connection_name=${tv['uv-connection-name']}    session_name=${tv['uv-session-name']}   sender_addr=${tv['uv-r0_r1-ip']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Test Probes Basic Info    owner=${tv['uv-connection-name']}   test_name=${tv['uv-session-name']}  srv_addr=${tv['uv-r1_r0-ip']}   srv_port=862   client_addr=${tv['uv-r0_r1-ip']}  reflct_addr=${tv['uv-r1_r0-ip']}  sender_addr=${tv['uv-r0_r1-ip']}   test_size=${tv['uv-probes-count']}
#     Verify Twamp Client Test Probes Single Results   rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes Current Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes One Sample Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Clear Twamp Server Connction All

#     ##Check restart whole system of Twamp Client
#     Start twamp client connction
#     Verify Twamp Server Control Connection  client_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}  server_addr=${tv['uv-r1_r0-ip']}   server_port=862   session_cnt=1
#     Verify Twamp Server Test Session    sender_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Control Connection    connection_name=${tv['uv-connection-name']}   client_addr=${tv['uv-r0_r1-ip']}   server_addr=${tv['uv-r1_r0-ip']}   server_port=862
#     Verify Twamp Client Test Session    connection_name=${tv['uv-connection-name']}    session_name=${tv['uv-session-name']}   sender_addr=${tv['uv-r0_r1-ip']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Test Probes Basic Info    owner=${tv['uv-connection-name']}   test_name=${tv['uv-session-name']}  srv_addr=${tv['uv-r1_r0-ip']}   srv_port=862   client_addr=${tv['uv-r0_r1-ip']}  reflct_addr=${tv['uv-r1_r0-ip']}  sender_addr=${tv['uv-r0_r1-ip']}   test_size=${tv['uv-probes-count']}
#     Verify Twamp Client Test Probes Single Results   rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes Current Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes One Sample Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Restart Twamp Server System
#     Verify Twamp Server the connection and session not exist
#     stop twamp client connction
#     Start twamp client connction
#     Verify Twamp Server Control Connection  client_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}  server_addr=${tv['uv-r1_r0-ip']}   server_port=862   session_cnt=1
#     Verify Twamp Server Test Session    sender_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Control Connection    connection_name=${tv['uv-connection-name']}   client_addr=${tv['uv-r0_r1-ip']}   server_addr=${tv['uv-r1_r0-ip']}   server_port=862
#     Verify Twamp Client Test Session    connection_name=${tv['uv-connection-name']}    session_name=${tv['uv-session-name']}   sender_addr=${tv['uv-r0_r1-ip']}   reflector_addr=${tv['uv-r1_r0-ip']}
#     Verify Twamp Client Test Probes Basic Info    owner=${tv['uv-connection-name']}   test_name=${tv['uv-session-name']}  srv_addr=${tv['uv-r1_r0-ip']}   srv_port=862   client_addr=${tv['uv-r0_r1-ip']}  reflct_addr=${tv['uv-r1_r0-ip']}  sender_addr=${tv['uv-r0_r1-ip']}   test_size=${tv['uv-probes-count']}
#     Verify Twamp Client Test Probes Single Results   rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes Current Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Verify Twamp Client Test Probes One Sample Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
#     Clear Twamp Server Connction All

# TWAMP_Server_Flow_Mode_TC_6
#     [Documentation]
#     ...     Tc5.4-1  Verify CLI commit constraint check for twamp server request knobs
#     ...     Tc5.4-2  Verify CLI set and delete for twamp server request knobs

#     [Tags]  TWAMP_Server  Flow_Mode  CLI

#     Config the twamp server with basic config  client_network=${tv['uv-r0_r1-nm']}
#     Verify CLI Knob client address Constraints
#     Verify CLI Knob port Constraints
#     Verify CLI Knob max-connection-duration Constraints
#     Verify CLI Knob maximum-connections Constraints
#     Verify CLI Knob maximum-connections-per-client Constraints
#     Verify CLI Knob maximum-sessions Constraints
#     Verify CLI Knob maximum-sessions-per-connection Constraints
#     Verify CLI Knob server-inactivity-timeout Constraints

#     #Check CLI knob configure and delete
#     Verify CLI Knob client address configure and delete
#     Verify CLI Knob max-connection-duration configure and delete
#     Verify CLI Knob routing instance configure and delete  interface=${tv['r1__r1r0__pic']}
#     Verify CLI Knob maximum-connections configure and delete
#     Verify CLI Knob maximum-connections-per-client configure and delete
#     Verify CLI Knob maximum-sessions configure and delete
#     Verify CLI Knob maximum-sessions-per-connection configure and delete
#     Verify CLI Knob server-inactivity-timeout configure and delete



