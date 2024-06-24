# Run this command with PowerShell to validate that a port on another machine is open


    Test-NetConnection -Port 53 -ComputerName 192.168.0.1 -InformationLevel Detailed

# Typical output

    ComputerName            : 192.168.0.1
    RemoteAddress           : 192.168.0.1
    RemotePort              : 53
    NameResolutionResults   : 192.168.0.1
                              aaa.bbb.ccc
    MatchingIPsecRules      : 
    NetworkIsolationContext : Private Network
    IsAdmin                 : False
    InterfaceAlias          : Ethernet
    SourceAddress           : 192.168.0.##
    NetRoute (NextHop)      : 0.0.0.0
    TcpTestSucceeded        : True



   # References
   https://stackoverflow.com/questions/273159/how-do-i-determine-if-a-port-is-open-on-a-windows-server
