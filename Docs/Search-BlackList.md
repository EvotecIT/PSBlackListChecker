---
external help file: PSBlackListChecker-help.xml
Module Name: PSBlackListChecker
online version:
schema: 2.0.0
---

# Search-BlackList

## SYNOPSIS
{{Fill in the Synopsis}}

## SYNTAX

```
Search-BlackList [[-IPs] <String[]>] [[-BlacklistServers] <String[]>] [-ReturnAll] [[-RunType] <String>]
 [[-SortBy] <String>] [-SortDescending] [-QuickTimeout] [[-MaxRunspaces] <Int32>] [-ExtendedOutput]
 [<CommonParameters>]
```

## DESCRIPTION
{{Fill in the Description}}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -BlacklistServers
{{Fill BlacklistServers Description}}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExtendedOutput
{{Fill ExtendedOutput Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IPs
{{Fill IPs Description}}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: IP

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxRunspaces
{{Fill MaxRunspaces Description}}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -QuickTimeout
{{Fill QuickTimeout Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReturnAll
{{Fill ReturnAll Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RunType
{{Fill RunType Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: NoWorkflowAndRunSpaceNetDNS, NoWorkflowAndRunSpaceResolveDNS, RunSpaceWithResolveDNS, RunSpaceWithNetDNS, WorkflowResolveDNS, WorkflowWithNetDNS

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SortBy
{{Fill SortBy Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: IP, BlackList, IsListed, Answer, FQDN

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SortDescending
{{Fill SortDescending Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
