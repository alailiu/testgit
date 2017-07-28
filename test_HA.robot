Documentation                       RLI35194 Support TWAMP Server on Siege/Forge (Moto)
...             Author             : Jianming Zhang
...             Date               : 06/15/2017
...             JTMS TEST PLAN     : http://systest.juniper.net/feature_testplan/44251/1.1
...             RLI                : 35194
...             MIN RELEASE        : 15.1
...             MAIN FEATURE       : TWAMP Client
...             Platform Supported : SRX300, SRX320, SRX340, SRX345, SRX550m, SRX1500
...             CUSTOMER           : Moto

*** Settings ***
Resource   jnpr/toby/Master.robot
Resource   151_RLI35194_SRX_Twamp_Server_util.robot
Suite Setup      Run Keywords
...     Toby Suite Setup
...     Initialize the test environment of HA
...     Init the configurations of HA topology
Suite Teardown    Run Keywords
...    Toby Suite Teardown
#...    Cleanup toby configuration files on device    @{dh_list}

Test Setup     Toby Test Setup
Test Teardown    Run Keywords
...    Stop twamp client connction
...    Delete the Twamp Configuration
...    Restore the routing instance to default
...    Restore the interface with no policy for HA
...    Toby Test Teardown

*** Variables ***


*** Test Cases ***
TWAMP_Server_HA_TC_1
    [Documentation]
    ...     Tc5.1-1  Verify TWAMP Server basic function with default values
    ...     Tc5.1-9  Verify the function of port for tcp connection

    [Tags]  TWAMP_Server  Flow_Mode

    #Check Twamp Server basic function with default values
    Config the twamp client with basic config  connection_name=${tv['uv-connection-name']}   session_name=${tv['uv-session-name']}  target_addr=${tv['uv-r1_r0-ip']}  probe_count=${tv['uv-probes-count']}
    Config the twamp server with basic config  client_network=${tv['uv-r0_r1-nm']}
    Start twamp client connction
    Initialize Verification Engine    151_RLI35194_SRX_Twamp_Server.verify.yaml
    Verify Twamp Server Control Connection  client_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}  server_addr=${tv['uv-r1_r0-ip']}   server_port=862   session_cnt=1
    Verify Twamp Server Test Session    sender_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}   reflector_addr=${tv['uv-r1_r0-ip']}
    Verify Twamp Client Control Connection    connection_name=${tv['uv-connection-name']}   client_addr=${tv['uv-r0_r1-ip']}   server_addr=${tv['uv-r1_r0-ip']}   server_port=862
    Verify Twamp Client Test Session    connection_name=${tv['uv-connection-name']}    session_name=${tv['uv-session-name']}   sender_addr=${tv['uv-r0_r1-ip']}   reflector_addr=${tv['uv-r1_r0-ip']}
    Verify Twamp Client Test Probes Basic Info    owner=${tv['uv-connection-name']}   test_name=${tv['uv-session-name']}  srv_addr=${tv['uv-r1_r0-ip']}   srv_port=862   client_addr=${tv['uv-r0_r1-ip']}  reflct_addr=${tv['uv-r1_r0-ip']}  sender_addr=${tv['uv-r0_r1-ip']}   test_size=${tv['uv-probes-count']}
    Verify Twamp Client Test Probes Single Results   rtt_range=${tv['uv-rtt-range']}
    Verify Twamp Client Test Probes Current Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
    Verify Twamp Client Test Probes One Sample Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
    Stop twamp client connction

    #Check function of port for tcp connction
    Configure Twamp Server Port  port=${tv['uv-port']}
    Configure Twamp Client Connection Destination Port   connection_name=${tv['uv-connection-name']}   port=${tv['uv-port']}
    Start twamp client connction
    Verify Twamp Server Connection Port  port=${tv['uv-port']}
    Verify Twamp Server Control Connection  client_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}  server_addr=${tv['uv-r1_r0-ip']}   server_port=${tv['uv-port']}   session_cnt=1
    Verify Twamp Server Test Session    sender_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}   reflector_addr=${tv['uv-r1_r0-ip']}
    Verify Twamp Client Control Connection    connection_name=${tv['uv-connection-name']}   client_addr=${tv['uv-r0_r1-ip']}   server_addr=${tv['uv-r1_r0-ip']}   server_port=${tv['uv-port']}
    Verify Twamp Client Test Session    connection_name=${tv['uv-connection-name']}    session_name=${tv['uv-session-name']}   sender_addr=${tv['uv-r0_r1-ip']}   reflector_addr=${tv['uv-r1_r0-ip']}
    Verify Twamp Client Test Probes Basic Info    owner=${tv['uv-connection-name']}   test_name=${tv['uv-session-name']}  srv_addr=${tv['uv-r1_r0-ip']}   srv_port=${tv['uv-port']}    client_addr=${tv['uv-r0_r1-ip']}  reflct_addr=${tv['uv-r1_r0-ip']}  sender_addr=${tv['uv-r0_r1-ip']}   test_size=${tv['uv-probes-count']}
    Verify Twamp Client Test Probes Single Results   rtt_range=${tv['uv-rtt-range']}
    Verify Twamp Client Test Probes Current Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
    Verify Twamp Client Test Probes One Sample Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
    Stop twamp client connction


TWAMP_Server_HA_TC_2
    [Documentation]
    ...     Tc5.1-4  Verify the functioning of maximum-sessions
    ...     Tc5.1-5  Verify the functioning of maximum sessions per connection
    ...     Tc6-3  Verify TWAMP Scaling with default Max Sessions
    ...     Tc6-4  Verify TWAMP Scaling with default Max sessions per connection.
    ...     Tc6-5  Verify TWAMP Scaling for Baselined numbers


    [Tags]  TWAMP_Server  Flow_Mode

    #check maximum-connections
    Configure Twamp Client for sessions default scaling
    Config the twamp server with basic config  client_network=${tv['uv-r0_r1-nm']}

    Start twamp client connction
    Verify Twamp Server Total Session Count  session_cnt=${64}
    Verify Twamp Server Sesson Count Per Connection  sess_cnt_conn=64
    Stop twamp client connction
    Congiure Twamp Server Maximum Sessions  session_cnt=${63}

    Start twamp client connction
    Verify Twamp Server the connection and session not exist
    Delete one session under the connection   session=t64
    Start twamp client connction
    Verify Twamp Server Total Session Count  session_cnt=${63}
    Stop twamp client connction
    Congiure Twamp Server Maximum Sessions Per Connecton   session_cnt_percon=62
    Start twamp client connction
    Verify Twamp Server the connection and session not exist
    Delete one session under the connection   session=t63
    Start twamp client connction
    Verify Twamp Server Total Session Count  session_cnt=${62}
    Stop twamp client connction


TWAMP_Server_HA_TC_3
    [Documentation]
    ...     Tc5.1-6  TWAMP server should abort test sessions which timeout.
    ...     Tc5.1-7  TWAMP session should be aborted when server issues clear connection
    ...     Tc5.1-8  TWAMP inactivity timeout when set to 0 should never terminate connection

    [Tags]  TWAMP_Server  Flow_Mode

    #Check the server-inactivity-timeout function
    Config the twamp client with basic config  connection_name=${tv['uv-connection-name']}   session_name=${tv['uv-session-name']}  target_addr=${tv['uv-r1_r0-ip']}  probe_count=${tv['uv-probes-count']}
    Config the twamp server with basic config  client_network=${tv['uv-r0_r1-nm']}
    Configure Twamp Server inactivity timeout  timeout=${tv['uv-inact-timeout']}

    Start twamp client connction
    Initialize Verification Engine    151_RLI35194_SRX_Twamp_Server.verify.yaml
    Verify Twamp Server Control Connection  client_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}  server_addr=${tv['uv-r1_r0-ip']}   server_port=862   session_cnt=1
    Verify Twamp Server Test Session    sender_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}   reflector_addr=${tv['uv-r1_r0-ip']}
    Verify Twamp Client Control Connection    connection_name=${tv['uv-connection-name']}   client_addr=${tv['uv-r0_r1-ip']}   server_addr=${tv['uv-r1_r0-ip']}   server_port=862
    Verify Twamp Client Test Session    connection_name=${tv['uv-connection-name']}    session_name=${tv['uv-session-name']}   sender_addr=${tv['uv-r0_r1-ip']}   reflector_addr=${tv['uv-r1_r0-ip']}
    Verify Twamp Client Test Probes Basic Info    owner=${tv['uv-connection-name']}   test_name=${tv['uv-session-name']}  srv_addr=${tv['uv-r1_r0-ip']}   srv_port=862   client_addr=${tv['uv-r0_r1-ip']}  reflct_addr=${tv['uv-r1_r0-ip']}  sender_addr=${tv['uv-r0_r1-ip']}   test_size=${tv['uv-probes-count']}
    Verify Twamp Client Test Probes Single Results   rtt_range=${tv['uv-rtt-range']}
    Verify Twamp Client Test Probes Current Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
    Verify Twamp Client Test Probes One Sample Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
    Stop twamp client connction
    Verify Twamp Server the connection and session not exist
    Verify Twamp Client Control Connection is Stopped
    Verify Twamp Client Test Session is Stopped
    sleep  10s
    Configure Twamp Server inactivity timeout  timeout=0
    Start twamp client connction
    Verify Twamp Server Control Connection  client_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}  server_addr=${tv['uv-r1_r0-ip']}   server_port=862   session_cnt=1
    Verify Twamp Server Test Session    sender_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}   reflector_addr=${tv['uv-r1_r0-ip']}
    Verify Twamp Client Control Connection    connection_name=${tv['uv-connection-name']}   client_addr=${tv['uv-r0_r1-ip']}   server_addr=${tv['uv-r1_r0-ip']}   server_port=862
    Verify Twamp Client Test Session    connection_name=${tv['uv-connection-name']}    session_name=${tv['uv-session-name']}   sender_addr=${tv['uv-r0_r1-ip']}   reflector_addr=${tv['uv-r1_r0-ip']}
    Verify Twamp Client Test Probes Basic Info    owner=${tv['uv-connection-name']}   test_name=${tv['uv-session-name']}  srv_addr=${tv['uv-r1_r0-ip']}   srv_port=862   client_addr=${tv['uv-r0_r1-ip']}  reflct_addr=${tv['uv-r1_r0-ip']}  sender_addr=${tv['uv-r0_r1-ip']}   test_size=${tv['uv-probes-count']}
    Verify Twamp Client Test Probes Single Results   rtt_range=${tv['uv-rtt-range']}
    Verify Twamp Client Test Probes Current Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
    Verify Twamp Client Test Probes One Sample Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
    Clear Twamp Server Connction All
    Verify Twamp Server the connection and session not exist
    Verify Twamp Client Control Connection is Stopped
    Verify Twamp Client Test Session is Stopped


    #check the clear service rpm twamp server connection function
    Start twamp client connction
    Initialize Verification Engine    151_RLI35194_SRX_Twamp_Server.verify.yaml
    Verify Twamp Server Control Connection  client_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}  server_addr=${tv['uv-r1_r0-ip']}   server_port=862   session_cnt=1
    Verify Twamp Server Test Session    sender_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}   reflector_addr=${tv['uv-r1_r0-ip']}
    Verify Twamp Client Control Connection    connection_name=${tv['uv-connection-name']}   client_addr=${tv['uv-r0_r1-ip']}   server_addr=${tv['uv-r1_r0-ip']}   server_port=862
    Verify Twamp Client Test Session    connection_name=${tv['uv-connection-name']}    session_name=${tv['uv-session-name']}   sender_addr=${tv['uv-r0_r1-ip']}   reflector_addr=${tv['uv-r1_r0-ip']}
    Verify Twamp Client Test Probes Basic Info    owner=${tv['uv-connection-name']}   test_name=${tv['uv-session-name']}  srv_addr=${tv['uv-r1_r0-ip']}   srv_port=862   client_addr=${tv['uv-r0_r1-ip']}  reflct_addr=${tv['uv-r1_r0-ip']}  sender_addr=${tv['uv-r0_r1-ip']}   test_size=${tv['uv-probes-count']}
    Verify Twamp Client Test Probes Single Results   rtt_range=${tv['uv-rtt-range']}
    Verify Twamp Client Test Probes Current Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
    Verify Twamp Client Test Probes One Sample Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
    Clear Twamp Server Connction All
    Verify Twamp Server the connection and session not exist
    Verify Twamp Client Control Connection is Stopped
    Verify Twamp Client Test Session is Stopped
    Start twamp client connction
    ${conn_id}   Get Connection ID on Twamp Server
    Clear Twamp Server Connection ID   ID=${conn_id}
    Verify Twamp Server the connection and session not exist
    Verify Twamp Client Control Connection is Stopped
    Verify Twamp Client Test Session is Stopped

TWAMP_Server_HA_TC_4
    [Documentation]
    ...     Tc5.1-11  Verify the functioning of routing-instance-list
    ...     Tc5.1-12  TWAMP session packets with Filter
    ...     Tc5.1-13  TWAMP sessions should not be established if client is removed from allowed client list.

    [Tags]  TWAMP_Server  Flow_Mode

    #Check Twamp sessions can't establish if removed from client
    Config the twamp client with basic config  connection_name=${tv['uv-connection-name']}   session_name=${tv['uv-session-name']}  target_addr=${tv['uv-r1_r0-ip']}  probe_count=${tv['uv-probes-count']}
    Config the twamp server with basic config  client_network=${tv['uv-r0_r1-nm']}
    Start twamp client connction
    Initialize Verification Engine    151_RLI35194_SRX_Twamp_Server.verify.yaml
    Verify Twamp Server Control Connection  client_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}  server_addr=${tv['uv-r1_r0-ip']}   server_port=862   session_cnt=1
    Verify Twamp Server Test Session    sender_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}   reflector_addr=${tv['uv-r1_r0-ip']}
    Verify Twamp Client Control Connection    connection_name=${tv['uv-connection-name']}   client_addr=${tv['uv-r0_r1-ip']}   server_addr=${tv['uv-r1_r0-ip']}   server_port=862
    Verify Twamp Client Test Session    connection_name=${tv['uv-connection-name']}    session_name=${tv['uv-session-name']}   sender_addr=${tv['uv-r0_r1-ip']}   reflector_addr=${tv['uv-r1_r0-ip']}
    Verify Twamp Client Test Probes Basic Info    owner=${tv['uv-connection-name']}   test_name=${tv['uv-session-name']}  srv_addr=${tv['uv-r1_r0-ip']}   srv_port=862   client_addr=${tv['uv-r0_r1-ip']}  reflct_addr=${tv['uv-r1_r0-ip']}  sender_addr=${tv['uv-r0_r1-ip']}   test_size=${tv['uv-probes-count']}
    Verify Twamp Client Test Probes Single Results   rtt_range=${tv['uv-rtt-range']}
    Verify Twamp Client Test Probes Current Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
    Verify Twamp Client Test Probes One Sample Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
    Stop twamp client connction
    Remove the twamp Client from Client list   client_nm=${tv['uv-r0_r1-nm']}
    Start twamp client connction
    Verify Twamp Server the connection and session not exist
    Config the twamp server with basic config  client_network=${tv['uv-r0_r1-nm']}
    Start twamp client connction
    Verify Twamp Server Control Connection  client_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}  server_addr=${tv['uv-r1_r0-ip']}   server_port=862   session_cnt=1
    Verify Twamp Server Test Session    sender_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}   reflector_addr=${tv['uv-r1_r0-ip']}
    Verify Twamp Client Control Connection    connection_name=${tv['uv-connection-name']}   client_addr=${tv['uv-r0_r1-ip']}   server_addr=${tv['uv-r1_r0-ip']}   server_port=862
    Verify Twamp Client Test Session    connection_name=${tv['uv-connection-name']}    session_name=${tv['uv-session-name']}   sender_addr=${tv['uv-r0_r1-ip']}   reflector_addr=${tv['uv-r1_r0-ip']}
    Verify Twamp Client Test Probes Basic Info    owner=${tv['uv-connection-name']}   test_name=${tv['uv-session-name']}  srv_addr=${tv['uv-r1_r0-ip']}   srv_port=862   client_addr=${tv['uv-r0_r1-ip']}  reflct_addr=${tv['uv-r1_r0-ip']}  sender_addr=${tv['uv-r0_r1-ip']}   test_size=${tv['uv-probes-count']}
    Verify Twamp Client Test Probes Single Results   rtt_range=${tv['uv-rtt-range']}
    Verify Twamp Client Test Probes Current Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
    Verify Twamp Client Test Probes One Sample Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
    Stop twamp client connction

    #Check the session work with filter
    Clear Twamp Server Connction All
    Configure Firewall Filter to Permit the Twamp Packets  client_ip=${tv['uv-r0_r1-ip']}  interface=reth0
    Start twamp client connction
    Verify Twamp Server Control Connection  client_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}  server_addr=${tv['uv-r1_r0-ip']}   server_port=862   session_cnt=1
    Verify Twamp Server Test Session    sender_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}   reflector_addr=${tv['uv-r1_r0-ip']}
    Verify Twamp Client Control Connection    connection_name=${tv['uv-connection-name']}   client_addr=${tv['uv-r0_r1-ip']}   server_addr=${tv['uv-r1_r0-ip']}   server_port=862
    Verify Twamp Client Test Session    connection_name=${tv['uv-connection-name']}    session_name=${tv['uv-session-name']}   sender_addr=${tv['uv-r0_r1-ip']}   reflector_addr=${tv['uv-r1_r0-ip']}
    Verify Twamp Client Test Probes Basic Info    owner=${tv['uv-connection-name']}   test_name=${tv['uv-session-name']}  srv_addr=${tv['uv-r1_r0-ip']}   srv_port=862   client_addr=${tv['uv-r0_r1-ip']}  reflct_addr=${tv['uv-r1_r0-ip']}  sender_addr=${tv['uv-r0_r1-ip']}   test_size=${tv['uv-probes-count']}
    Verify Twamp Client Test Probes Single Results   rtt_range=${tv['uv-rtt-range']}
    Verify Twamp Client Test Probes Current Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
    Verify Twamp Client Test Probes One Sample Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
    Stop twamp client connction

    #Check the functioning of routing-instance-list

    Configure Routing Instance on Twamp Server  instance_name=${tv['uv-routing-instance']}    interface=reth0  client_ip=${tv['uv-r0_r1-ip']}
    Configure Routing Instance Options In TWAMP Server  instance=${tv['uv-routing-instance']}   port=${tv['uv-port']}
    Configure Twamp Client Connection Destination Port   connection_name=${tv['uv-connection-name']}   port=${tv['uv-port']}

    sleep  10s
    Start twamp client connction
    Verify Twamp Server Control Connection  client_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}  server_addr=${tv['uv-r1_r0-ip']}   server_port=${tv['uv-port']}   session_cnt=1
    Verify Twamp Server Test Session    sender_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}   reflector_addr=${tv['uv-r1_r0-ip']}
    Verify Twamp Client Control Connection    connection_name=${tv['uv-connection-name']}   client_addr=${tv['uv-r0_r1-ip']}   server_addr=${tv['uv-r1_r0-ip']}   server_port=${tv['uv-port']}
    Verify Twamp Client Test Session    connection_name=${tv['uv-connection-name']}    session_name=${tv['uv-session-name']}   sender_addr=${tv['uv-r0_r1-ip']}   reflector_addr=${tv['uv-r1_r0-ip']}
    Verify Twamp Client Test Probes Basic Info    owner=${tv['uv-connection-name']}   test_name=${tv['uv-session-name']}  srv_addr=${tv['uv-r1_r0-ip']}   srv_port=${tv['uv-port']}   client_addr=${tv['uv-r0_r1-ip']}  reflct_addr=${tv['uv-r1_r0-ip']}  sender_addr=${tv['uv-r0_r1-ip']}   test_size=${tv['uv-probes-count']}
    Verify Twamp Client Test Probes Single Results   rtt_range=${tv['uv-rtt-range']}
    Verify Twamp Client Test Probes Current Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
    Verify Twamp Client Test Probes One Sample Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
    Stop twamp client connction
    Restore the interface with no policy for HA

TWAMP_Server_HA_TC_5
    [Documentation]
    ...     Tc7-1 Verify TWAMP control-connection and test session work on HA

    [Tags]  TWAMP_Server  HA

    Config the twamp client with basic config  connection_name=${tv['uv-connection-name']}   session_name=${tv['uv-session-name']}  target_addr=${tv['uv-r1_r0-ip']}  probe_count=${tv['uv-probes-count']}
    Config the twamp server with basic config  client_network=${tv['uv-r0_r1-nm']}
    Start twamp client connction
    Initialize Verification Engine    151_RLI35194_SRX_Twamp_Server.verify.yaml
    Verify Twamp Server Control Connection  client_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}  server_addr=${tv['uv-r1_r0-ip']}   server_port=862   session_cnt=1
    Verify Twamp Server Test Session    sender_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}   reflector_addr=${tv['uv-r1_r0-ip']}
    Verify Twamp Client Control Connection    connection_name=${tv['uv-connection-name']}   client_addr=${tv['uv-r0_r1-ip']}   server_addr=${tv['uv-r1_r0-ip']}   server_port=862
    Verify Twamp Client Test Session    connection_name=${tv['uv-connection-name']}    session_name=${tv['uv-session-name']}   sender_addr=${tv['uv-r0_r1-ip']}   reflector_addr=${tv['uv-r1_r0-ip']}
    Verify Twamp Client Test Probes Basic Info    owner=${tv['uv-connection-name']}   test_name=${tv['uv-session-name']}  srv_addr=${tv['uv-r1_r0-ip']}   srv_port=862   client_addr=${tv['uv-r0_r1-ip']}  reflct_addr=${tv['uv-r1_r0-ip']}  sender_addr=${tv['uv-r0_r1-ip']}   test_size=${tv['uv-probes-count']}
    Verify Twamp Client Test Probes Single Results   rtt_range=${tv['uv-rtt-range']}
    Verify Twamp Client Test Probes Current Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
    Verify Twamp Client Test Probes One Sample Results  test_size=${tv['uv-probes-count']}  rtt_range=${tv['uv-rtt-range']}
    Failover the Reduandancy Group 1
    Verify Twamp Server Control Connection  client_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}  server_addr=${tv['uv-r1_r0-ip']}   server_port=862   session_cnt=1
    Verify Twamp Server Test Session    sender_addr=${tv['uv-r0_r1-ip']}   port_range=${tv['uv-port-range']}   reflector_addr=${tv['uv-r1_r0-ip']}
    Verify Twamp Client Control Connection    connection_name=${tv['uv-connection-name']}   client_addr=${tv['uv-r0_r1-ip']}   server_addr=${tv['uv-r1_r0-ip']}   server_port=862
    Verify Twamp Client Test Session    connection_name=${tv['uv-connection-name']}    session_name=${tv['uv-session-name']}   sender_addr=${tv['uv-r0_r1-ip']}   reflector_addr=${tv['uv-r1_r0-ip']}
    Verify Twamp Client Test Probes Basic Info    owner=${tv['uv-connection-name']}   test_name=${tv['uv-session-name']}  srv_addr=${tv['uv-r1_r0-ip']}   srv_port=862   client_addr=${tv['uv-r0_r1-ip']}  reflct_addr=${tv['uv-r1_r0-ip']}  sender_addr=${tv['uv-r0_r1-ip']}   test_size=${tv['uv-probes-count']}


















