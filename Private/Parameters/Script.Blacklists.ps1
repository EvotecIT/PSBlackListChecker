[string[]] $Script:BlackLists = @(
    'b.barracudacentral.org'
    'spam.rbl.msrbl.net'
    'zen.spamhaus.org'
    'bl.deadbeef.com'
    #'bl.emailbasura.org' dead as per https://github.com/EvotecIT/PSBlackListChecker/issues/8
    'bl.spamcop.net'
    'blackholes.five-ten-sg.com'
    'blacklist.woody.ch'
    'bogons.cymru.com'
    'cbl.abuseat.org'
    'combined.abuse.ch'
    'combined.rbl.msrbl.net'
    'db.wpbl.info'
    'dnsbl-1.uceprotect.net'
    'dnsbl-2.uceprotect.net'
    'dnsbl-3.uceprotect.net'
    'dnsbl.cyberlogic.net'
    'dnsbl.inps.de'
    #'dnsbl.sorbs.net' # https://github.com/EvotecIT/PSBlackListChecker/issues/11
    'drone.abuse.ch'
    'drone.abuse.ch'
    'duinv.aupads.org'
    'dul.dnsbl.sorbs.net'
    'dul.ru'
    'dyna.spamrats.com'
    # 'dynip.rothen.com' dead as per https://github.com/EvotecIT/PSBlackListChecker/issues/9
    #'http.dnsbl.sorbs.net' # https://github.com/EvotecIT/PSBlackListChecker/issues/11
    'images.rbl.msrbl.net'
    'ips.backscatterer.org'
    'ix.dnsbl.manitu.net'
    'korea.services.net'
    #'misc.dnsbl.sorbs.net' # https://github.com/EvotecIT/PSBlackListChecker/issues/11
    'noptr.spamrats.com'
    'ohps.dnsbl.net.au'
    'omrs.dnsbl.net.au'
    'orvedb.aupads.org'
    'osps.dnsbl.net.au'
    'osrs.dnsbl.net.au'
    'owfs.dnsbl.net.au'
    'owps.dnsbl.net.au'
    'pbl.spamhaus.org'
    'phishing.rbl.msrbl.net'
    'probes.dnsbl.net.au'
    'proxy.bl.gweep.ca'
    'proxy.block.transip.nl'
    'psbl.surriel.com'
    'rbl.interserver.net'
    'rdts.dnsbl.net.au'
    'relays.bl.gweep.ca'
    'relays.bl.kundenserver.de'
    'relays.nether.net'
    'residential.block.transip.nl'
    'ricn.dnsbl.net.au'
    'rmst.dnsbl.net.au'
    'sbl.spamhaus.org'
    'short.rbl.jp'
    #'smtp.dnsbl.sorbs.net' # https://github.com/EvotecIT/PSBlackListChecker/issues/11
    #'socks.dnsbl.sorbs.net' # https://github.com/EvotecIT/PSBlackListChecker/issues/11
    'spam.abuse.ch'
    #'spam.dnsbl.sorbs.net' # https://github.com/EvotecIT/PSBlackListChecker/issues/11
    'spam.spamrats.com'
    'spamlist.or.kr'
    'spamrbl.imp.ch'
    't3direct.dnsbl.net.au'
    'ubl.lashback.com'
    'ubl.unsubscore.com'
    'virbl.bit.nl'
    'virus.rbl.jp'
    'virus.rbl.msrbl.net'
    #'web.dnsbl.sorbs.net' # https://github.com/EvotecIT/PSBlackListChecker/issues/11
    'wormrbl.imp.ch'
    'xbl.spamhaus.org'
    #'zombie.dnsbl.sorbs.net' # https://github.com/EvotecIT/PSBlackListChecker/issues/11
    #'bl.spamcannibal.org' now a parked domain
    #'tor.ahbl.org' # as per https://ahbl.org/ was terminated in 2015
    #'tor.dnsbl.sectoor.de' parked domain
    #'torserver.tor.dnsbl.sectoor.de' as above
    #'dnsbl.njabl.org' # supposedly doesn't work properly anymore
    # 'dnsbl.ahbl.org' # as per https://ahbl.org/ was terminated in 2015
    # 'cdl.anti-spam.org.cn' Inactive
)