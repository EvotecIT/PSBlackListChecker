# PSBlackListChecker - PowerShell module
Full Description for this project at: https://evotec.xyz/hub/scripts/psblacklistchecker/
# Description:
Basic functionality of this module is ability to quickly verify if given IP address is on any of over 80 defined DNSBL lists. Below code will return results only if IP is on any of the lists. Advanced functionality of this module is ability to send reports to your email when things get bad on one of those 80 defined DNSBL listrs.


``` Time to execute
RunType                         BlackList All BlackList Found Time Minutes Time Seconds Time Milliseconds
-------                         ------------- --------------- ------------ ------------ -----------------
NoWorkflowAndRunSpaceNetDNS                78               3            0           50                57
NoWorkflowAndRunSpaceResolveDNS            78               3            0           38               980
WorkflowResolveDNS                         78               3            0           42               191
WorkflowWithNetDNS                         78               3            0           39               973
RunSpaceWithResolveDNS                     78               3            0           12               376
RunSpaceWithNetDNS                         78               3            0           10               615
```