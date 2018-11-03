# PSBlackListChecker - PowerShell module

[![Build status Appveyor](https://ci.appveyor.com/api/projects/status/k5mefm1r3ri0c71i?svg=true)](https://ci.appveyor.com/project/PrzemyslawKlys/psblacklistchecker)
[![Build Status Windows](https://dev.azure.com/evotecpl/PSBlackListChecker/_apis/build/status/EvotecIT.PSBlackListChecker)](https://dev.azure.com/evotecpl/PSBlackListChecker/_build/latest?definitionId=3)

# Short Description:
Basic functionality of this module is ability to quickly verify if given IP address is on any of over 80 defined DNSBL lists. Below code will return results only if IP is on any of the lists. Advanced functionality of this module is ability to send reports to your email when things get bad on one of those 80 defined DNSBL listrs.

Full Description for this project at: https://evotec.xyz/hub/scripts/psblacklistchecker/

## Functionality:
- [x] Manual Tests
- [x] Email Alerts (just **blacklisted**, or all)
- [x] Microsoft Teams Alerts (just **blacklisted**)
- [x] Slack Alerts (just **blacklisted**)


## Updates
- 0.6 - 2018.11.02 - [Full blog post](https://evotec.xyz/psblacklistchecker-notifications-to-microsoft-teams-slack-of-blacklisted-ips/)
    - Added Teams support
    - Added Slack support
    - Rewritten logic - added runspaces
- 0.3 - 2018.05.06
    - First working release
- 0.1 - 2018.04.27
    - First draft release


## Install How-To

```
Install-Module PSBlackListChecker
```

## Update How-To

```
Update-Module PSBlackListChecker
```


## Time to execute using different approaches

Following is a speed comparision table - By default RunSpaceWithResolveDNS is used, but you can overwrite it in settings.

```
RunType                         BlackList All BlackList Found Time Minutes Time Seconds Time Milliseconds
-------                         ------------- --------------- ------------ ------------ -----------------
NoWorkflowAndRunSpaceNetDNS                78               3            0           50                57
NoWorkflowAndRunSpaceResolveDNS            78               3            0           38               980
WorkflowResolveDNS                         78               3            0           42               191
WorkflowWithNetDNS                         78               3            0           39               973
RunSpaceWithResolveDNS                     78               3            0           12               376
RunSpaceWithNetDNS                         78               3            0           10               615
```


### Example output (Manual)

![image](https://evotec.xyz/wp-content/uploads/2018/04/img_5ae61b3ba2c75.png)

### Example screen (Email)

![image](https://evotec.xyz/wp-content/uploads/2018/04/img_5ae624e384d2c.png)


### Example screen (Microsoft Teams)

![image](https://evotec.xyz/wp-content/uploads/2018/11/img_5bdca1f52c3c8.png)


### Example screen (Slack)

![image](https://evotec.xyz/wp-content/uploads/2018/11/img_5bdca221efcaf.png)