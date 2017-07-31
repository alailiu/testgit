Documentation                       RLI35194 Support TWAMP Server on Siege/Forge (Moto)
...             Author             : Allen Ai Liu
...             Date               : 07/30/2017
...             JTMS TEST PLAN     : http://systest.juniper.net/feature_testplan/45429
...             RLI                : 36300
...             MIN RELEASE        : 15.1
...             MAIN FEATURE       : TWAMP Client
...             Platform Supported : SRX300, SRX320, SRX340, SRX345
...             CUSTOMER           : Moto

*** Settings ***
Resource   jnpr/toby/Master.robot
Resource   test_util.robot
Suite Setup      Run Keywords
...     Toby Suite Setup
...     Initialize the test environment of HA
...     Init the configurations of HA topology
...     Prepare test file on local and remote for HA
Suite Teardown   Run Keywords
...    Delete test files
...    Toby Suite Teardown

Test Setup     Run Keywords
...    Toby Test Setup
Test Teardown    Run Keywords
...    Delete copied files
...    Toby Test Teardown

*** Variables ***


*** Test Cases ***
SCP_TC_1
    [Documentation]
    ...     Tc5.1-12  scp on HA
    ...

    [Tags]  SCP HA

    Scp file from local to remote   server_ip=${tv['uv-r0_r1-ip']}
    Check copied file size   device=${server}  filename=testfilelocal  size=${filelocalsize}

    sleep   5s
    Scp file from remote to local   server_ip=${tv['uv-r0_r1-ip']}
    Check copied file size   device=${client}  filename=testfileremote  size=${fileremotesize}
    sleep   5s
    Delete copied files


    Failover the Reduandancy Group 1
    Reset the redundancy group 1
    Scp file from local to remote   server_ip=${tv['uv-r0_r1-ip']}
    Check copied file size   device=${server}  filename=testfilelocal  size=${filelocalsize}

    sleep   5s
    Scp file from remote to local   server_ip=${tv['uv-r0_r1-ip']}
    Check copied file size   device=${client}  filename=testfileremote  size=${fileremotesize}
    sleep   5s
    Delete copied files

    Failover the Reduandancy Group 0
    Set the primary node to handle
    Reset the redundancy group 0

    Scp file from remote to local   server_ip=${tv['uv-r0_r1-ip']}
    Check copied file size   device=${client}  filename=testfileremote  size=${fileremotesize}
    sleep   5s
    Delete copied files

    Failover the Reduandancy Group 0
    Set the primary node to handle
    Reset the redundancy group 0

    Set the secondary node to handle
    Scp file from remote to local no node1   server_ip=${t['resources']['r1']['system']['primary']['controllers']['re0']['mgt-ip']}
    Check copied file size   device=${client}  filename=testfilelocal  size=${filelocalsize}
    sleep   5s

















