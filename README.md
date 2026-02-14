<p align="center">
  <a href="https://www.powershellgallery.com/packages/PSBlackListChecker"><img src="https://img.shields.io/powershellgallery/v/PSBlackListChecker.svg"></a>
  <a href="https://www.powershellgallery.com/packages/PSBlackListChecker"><img src="https://img.shields.io/powershellgallery/v/PSBlackListChecker.svg?label=powershell%20gallery%20preview&colorB=yellow&include_prereleases"></a>
  <a href="https://github.com/EvotecIT/PSBlackListChecker"><img src="https://img.shields.io/github/license/EvotecIT/PSBlackListChecker.svg"></a>
  <a href="https://dev.azure.com/evotecpl/PSBlackListChecker/_build/latest?definitionId=3"><img src="https://dev.azure.com/evotecpl/PSBlackListChecker/_apis/build/status/EvotecIT.PSBlackListChecker"></a>
</p>

<p align="center">
  <a href="https://www.powershellgallery.com/packages/PSBlackListChecker"><img src="https://img.shields.io/powershellgallery/p/PSBlackListChecker.svg"></a>
  <a href="https://github.com/EvotecIT/PSBlackListChecker"><img src="https://img.shields.io/github/languages/top/evotecit/PSBlackListChecker.svg"></a>
  <a href="https://github.com/EvotecIT/PSBlackListChecker"><img src="https://img.shields.io/github/languages/code-size/evotecit/PSBlackListChecker.svg"></a>
  <a href="https://github.com/EvotecIT/PSBlackListChecker"><img src="https://img.shields.io/powershellgallery/dt/PSBlackListChecker.svg"></a>
</p>

<p align="center">
  <a href="https://twitter.com/PrzemyslawKlys"><img src="https://img.shields.io/twitter/follow/PrzemyslawKlys.svg?label=Twitter%20%40PrzemyslawKlys&style=social"></a>
  <a href="https://evotec.xyz/hub"><img src="https://img.shields.io/badge/Blog-evotec.xyz-2A6496.svg"></a>
  <a href="https://www.linkedin.com/in/pklys"><img src="https://img.shields.io/badge/LinkedIn-pklys-0077B5.svg?logo=LinkedIn"></a>
</p>

# PSBlackListChecker - PowerShell module

Basic functionality of this module is ability to quickly verify if given IP address is on any of over 80 defined DNSBL lists. Below code will return results only if IP is on any of the lists. Advanced functionality of this module is ability to send reports to your email when things get bad on one of those 80 defined DNSBL listrs.

Full Description for this project at: <https://evotec.xyz/hub/scripts/psblacklistchecker/>

## Functionality

- [x] Manual Tests
- [x] Email Alerts (just **blacklisted**, or all)
- [x] Microsoft Teams Alerts (just **blacklisted**)
- [x] Slack Alerts (just **blacklisted**)
- [x] Discord Alerts (just **blacklisted**)

## Changelog

- 0.8.7 - 2024.07.21
- - Remove `SORBS.NET` from Blacklists as per [#11](https://github.com/EvotecIT/PSBlackListChecker/issues/11)
- 0.8.6 - 2020.10.3
  - Removed blacklist (tnx williamb1024)
- 0.8.5 - 2019.11.1
  - Removed blacklist (tnx SNicolini)
- 0.8.4 - 2019.05.30
  - Removed some blacklists (tnx Narfmeister)
- 0.8.3 - 2019.05.26
  - Fix for email options (tnx lucwuyts)
- 0.8.2 - 2019.05.08
  - Removed few blacklists that seem dead (tnx Narfmeister)
- 0.7 - 2018.11.03 - [Full blog ppost](https://evotec.xyz/psblacklistchecker-added-discord-support/)
  - Added Discord support
- 0.6 - 2018.11.02 - [Full blog post](https://evotec.xyz/psblacklistchecker-notifications-to-microsoft-teams-slack-of-blacklisted-ips/)
  - Added Teams support
  - Added Slack support
  - Rewritten logic - added runspaces
- 0.3 - 2018.05.06
  - First working release
- 0.1 - 2018.04.27
  - First draft release

## Install How-To

```powershell
Install-Module PSBlackListChecker
```

## Update How-To

```powershell
Update-Module PSBlackListChecker
```

## Dependancy

This module has dependency on couple of modules that are installed along PSBlackListChecker. Just in case it doesn't install, or you do things manually make sure you have those:

```powershell
Install-Module PSTeams
Install-Module PSSharedGoods
Install-Module PSSlack
```

## Time to execute using different approaches

Following is a speed comparision table - By default RunSpaceWithResolveDNS is used, but you can overwrite it in settings.

```powershell
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

### Example screen (Discord)

![image](https://evotec.xyz/wp-content/uploads/2018/11/img_5bddf4c2bfdcc.png)
