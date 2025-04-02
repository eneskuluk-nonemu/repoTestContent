param workspace string

resource workspace_vimNetworkSessionCheckPoint 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  name: '${workspace}/vimNetworkSessionCheckPoint'
  location: resourceGroup().location
  properties: {
    etag: '*'
    displayName: 'Check Point Firewall Network Sessions'
    category: 'Security'
    functionAlias: 'vimNetworkSessionCheckPoint'
    query: 'let NetworkParserCheckPoint=(){\nCommonSecurityLog\n| where DeviceVendor=="Check Point" and DeviceProduct=="VPN-1 & FireWall-1"\n| project-rename \n    EventResourceId=_ResourceId\n    , EventVendor=DeviceVendor\n    , EventProduct=DeviceProduct\n    , NetworkProtocol=Protocol\n  , EventSeverity=LogSeverity \n    , SrcNatIpAddr=SourceTranslatedAddress\n    , SrcNatPortNumber=SourceTranslatedPort\n    , DstNatIpAddr=DestinationTranslatedAddress\n    , DstNatPortNumber=DestinationTranslatedPort\n    , DstBytes=ReceivedBytes\n    , SrcBytes=SentBytes\n    , DvcMacAddr=DeviceMacAddress\n    , DstDvcHostname=DestinationHostName\n    , DstMacAddr=DestinationMACAddress\n  , SrcMacAddr=SourceMACAddress\n  , DvcAction=DeviceAction\n| extend\n    EventSchemaVersion="1.0.0"\n  , EventCount=toint(1)\n  , EventUid=_ItemId\n    , EventOriginalUid=extract(@\'loguid=(\\{[^\\}]+\\})\',1,AdditionalExtensions, typeof(string))\n    , EventTimeIngested =ingestion_time()\n    , DvcHostname=extract(@\'originsicname=cn\\\\\\\\=([^,]+),\',1,AdditionalExtensions, typeof(string))\n    , EventType="Traffic"\n    , EventResult=case(isempty(DvcAction),"", DvcAction=="Accept","Success","Failure") \n    , SrcZone=extract(@\'inzone=([^;]+);\',1,AdditionalExtensions, typeof(string))\n    , DstZone=extract(@\'outzone=([^;]+);\',1,AdditionalExtensions, typeof(string))\n    , NetworkRuleName=iff (DvcAction=="Accept" ,"", coalesce( DeviceCustomString2 , extract(@\'(action_reason=|tcp_packet_out_of_state=)([^;]+)\',2,AdditionalExtensions, typeof(string)), Activity))\n    , NetworkApplicationProtocol=iff (DvcAction !="Accept", Activity,"")\n    , ["NetworkRuleNumber"]=extract(@"rule_uid=([0-9a-f\\x2d]+)",1, AdditionalExtensions)\n// Trivial rename for mitigating autocomplete\n| project-rename\n    NetworkDirection=CommunicationDirection\n    , EventEndTime=EndTime\n  , EventStartTime= StartTime\n  , EventMessage=Message\n  , TimeGenerated=TimeGenerated\n    , DstIpAddr=DestinationIP\n    , DstPortNumber=DestinationPort\n    , SrcPortNumber=SourcePort\n    , SrcIpAddr=SourceIP\n    , DstUserName=DestinationUserName\n  , DvcOutboundInterface=DeviceOutboundInterface\n  , DvcInboundInterface=DeviceInboundInterface\n  , SrcUserName=SourceUserName\n};\nNetworkParserCheckPoint'
    version: 1
  }
}
