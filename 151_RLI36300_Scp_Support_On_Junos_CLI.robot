Documentation                       RLI36300 scp support on Junos CLI with src-addr and vr options
...             Author             : Ai Liu
...             Date               : 07/25/2017
...             JTMS TEST PLAN     : http://systest.juniper.net/feature_testplan/45429
...             RLI                : 36300
...             MIN RELEASE        : 15.1
...             MAIN FEATURE       : scp CLI
...             Platform Supported : SRX300, SRX320, SRX340, SRX345, SRX550m
...             CUSTOMER           : Swift


*** Settings ***
Resource   jnpr/toby/Master.robot
Resource   151_RLI36300_Scp_Support_On_Junos_CLI_util.robot
Suite Setup      Run Keywords
...     Toby Suite Setup
...     Initialize the test environment of Topology with two nodes
...     Check all the devices on Flow Mode
...     Init the Configurations on two nodes in Flow Mode
...     Prepare test file on local and remote
#Suite Teardown   Cleanup toby configuration files on device    @{dh_list}

Suite Teardown   Run Keywords
...    Delete test files
...    Clear the Configurations on two nodes in Flow Mode
...    Toby Suite Teardown

Test Setup     Run Keywords
...    Toby Test Setup
Test Teardown   Run Keywords
...    Delete copied files
...    Toby Test Teardown



*** Variables ***



*** Test Cases ***
SCP_TC_1
    [Documentation]
    ...     Tc5.1-1  in default routing instance,scp file from local to remote
    ...     Tc5.1-2  in default routing instance,scp file from remote to local

    [Tags]  scp


    Scp file from local to remote   server_ip=${tv['uv-r1_r0-ip']}
    Check copied file size   device=${server}  filename=testfilelocal  size=${filelocalsize}

    sleep   5s
    Scp file from remote to local   server_ip=${tv['uv-r1_r0-ip']}
    Check copied file size   device=${client}  filename=testfileremote  size=${fileremotesize}
    sleep   5s
    Delete copied files

    Scp file from local to remote   server_ip=${t['resources']['r1']['system']['primary']['controllers']['re0']['hostname']}
    Check copied file size   device=${server}  filename=testfilelocal  size=${filelocalsize}

    sleep   5s
    Scp file from remote to local   server_ip=${t['resources']['r1']['system']['primary']['controllers']['re0']['hostname']}
    Check copied file size   device=${client}  filename=testfileremote  size=${fileremotesize}
    sleep   5s


SCP_TC_2
    [Documentation]
    ...     Tc5.1-3  in default routing instance,scp file from local to remote with source-address
    ...     Tc5.1-4  in default routing instance,scp file from remote to local with source-address

    [Tags]  scp with source address


    Scp file from local to remote with source address  server_ip=${tv['uv-r1_r0-ip-lo']}  source_addr=${tv['uv-r0_r1-ip-lo']}
    Check copied file size   device=${server}  filename=testfilelocal  size=${filelocalsize}

    sleep   5s
    Scp file from remote to local with source address  server_ip=${tv['uv-r1_r0-ip-lo']}  source_addr=${tv['uv-r0_r1-ip-lo']}
    Check copied file size   device=${client}  filename=testfileremote  size=${fileremotesize}
    sleep   5s

SCP_TC_3
    [Documentation]
    ...     Tc5.1-9  in default routing instance,scp file from local to remote for ipv6
    ...     Tc5.1-9  in default routing instance,scp file from remote to local for ipv6

    [Tags]  scp


    Scp file from local to remote   server_ip=[${tv['uv-r1_r0-ip6']}]
    Check copied file size   device=${server}  filename=testfilelocal  size=${filelocalsize}

    sleep   5s
    Scp file from remote to local   server_ip=[${tv['uv-r1_r0-ip6']}]
    Check copied file size   device=${client}  filename=testfileremote  size=${fileremotesize}
    sleep   5s

SCP_TC_4
    [Documentation]
    ...     Tc5.1-9  in default routing instance,scp file from local to remote with source-address for ipv6
    ...     Tc5.1-9  in default routing instance,scp file from remote to local with source-address for ipv6

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
    ...     Tc5.1-5  in routing instance,scp file from local to remote in routing instance
    ...     Tc5.1-6  in routing instance,scp file from remote to local in routing instance
    [Tags]  scp with in routing instance


    Scp file from local to remote in routing instance   server_ip=${tv['uv-r1_r0-ip2']}
    Check copied file size   device=${server}  filename=testfilelocal  size=${filelocalsize}
    sleep   5s
    Scp file from remote to local in routing instance   server_ip=${tv['uv-r1_r0-ip2']}
    Check copied file size   device=${client}  filename=testfileremote  size=${fileremotesize}
    sleep   5s


SCP_TC_6
    [Documentation]
    ...     Tc5.1-7  in routing instance,scp file from local to remote with source-address in routing instance
    ...     Tc5.1-8  in routing instance,scp file from remote to local with source-address in routing instance
    [Tags]  scp with in routing instance



    Scp file from local to remote with source address in routing instance   server_ip=${tv['uv-r1_r0-ip-lo']}  source_addr=${tv['uv-r0_r1-ip-lo2']}
    Check copied file size   device=${server}  filename=testfilelocal  size=${filelocalsize}
    sleep   5s

    Scp file from remote to local with source address in routing instance   server_ip=${tv['uv-r1_r0-ip-lo']}  source_addr=${tv['uv-r0_r1-ip-lo2']}
    Check copied file size   device=${client}  filename=testfileremote  size=${fileremotesize}
    sleep   5s

SCP_TC_7
    [Documentation]
    ...     Tc5.1-5  in routing instance,scp file from local to remote in routing instance for ipv6
    ...     Tc5.1-6  in routing instance,scp file from remote to local in routing instance for ipv6
    [Tags]  scp with in routing instance




    Scp file from local to remote in routing instance  server_ip=[${tv['uv-r1_r0-ip6-lo']}]
    Check copied file size   device=${server}  filename=testfilelocal  size=${filelocalsize}

    sleep   5s
    Scp file from remote to local in routing instance  server_ip=[${tv['uv-r1_r0-ip6-lo']}]
    Check copied file size   device=${client}  filename=testfileremote  size=${fileremotesize}

    sleep   5s

SCP_TC_8
    [Documentation]
    ...     Tc5.1-7  in routing instance,scp file from local to remote with source-address in routing instance for ipv6
    ...     Tc5.1-8  in routing instance,scp file from remote to local with source-address in routing instance for ipv6
    [Tags]  scp with in routing instance



    Scp file from local to remote with source address in routing instance  server_ip=[${tv['uv-r1_r0-ip6-lo']}]  source_addr=${tv['uv-r0_r1-ip6-lo2']}
    Check copied file size   device=${server}  filename=testfilelocal  size=${filelocalsize}

    sleep   5s
    Scp file from remote to local with source address in routing instance  server_ip=[${tv['uv-r1_r0-ip6-lo']}]  source_addr=${tv['uv-r0_r1-ip6-lo2']}
    Check copied file size   device=${client}  filename=testfileremote  size=${fileremotesize}
    sleep   5s



SCP_TC_9
    [Documentation]
    ...     Tc5.1-10  scp authenticity test
    [Tags]  scp command interactive test
    Scp interactive test


SCP_TC_10
    [Documentation]
    ...     Tc5.1-11  scp with recursive option
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
    ...     Tc5.1-12  multiple scp test
    [Tags]  multiple scp test

    Scp file from local to remote   server_ip=${tv['uv-r1_r0-ip']}
    Check copied file size   device=${server}  filename=testfilelocal  size=${filelocalsize}
    Scp folder from local to remote in routing instance   server_ip=${tv['uv-r1_r0-ip2']}
    Check copied file size   device=${server}  filename=folder/testfilelocal  size=${filelocalsize}


