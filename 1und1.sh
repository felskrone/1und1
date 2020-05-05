#!/bin/bash
START_DATE="$(date +"%Y-%m-%d_%H:%m:%S")"
TEST_FQDNS="www.heise.de www.google.de www.youtube.de www.1und1.de sip.1und1.de www.gmx.de"
DNS1="8.8.8.8"
DNS2="208.67.222.222"
OUTFILE="dsl_analyzer_$(date +"%Y-%m-%d").log"
PCOUNT=3

rm -f ${OUTFILE}

function me() {
    echo -e "${1}" >> ${OUTFILE}
}

me "### START MacOS IP Configuration ###"
ifconfig >> ${OUTFILE}
me "### END MACOs IP Configuration ###\n\n"

me "### START route ip4 ###"
netstat -rn -f inet >> ${OUTFILE}
me "### END route ip4 ###\n\n"

me "### START route ip6 ###"
netstat -rn -f inet6 >> ${OUTFILE}
me "### END route ip6###\n\n"

for host in ${TEST_FQDNS}
do    
    me "Starte Test ${host}"
    me "####################################################"
    me "### Start $(date +"%Y-%m-%d_%H%m%S")"
    me "-- DNS-Test mit Kundeneinstellungen"
    nslookup ${host} 2>&1 >> ${OUTFILE}  2>&1
    me "-- DNS-Test ueber ${DNS1}"
    nslookup ${host} ${DNS1} >> ${OUTFILE}  2>&1
    me "-- DNS-Test ueber ${DNS2}"
    nslookup ${host} ${DNS2} >> ${OUTFILE}  2>&1
    me " -- MTR/Tracert ${host} mit IPv4"
    me "mtr -n -4 -r -c5 ${host}"
    mtr -n -4 -r -c5 ${host} >> ${OUTFILE}  2>&1
    me "------------"
    me "-- MTR/Tracert ${host} mit IPv6"
    me "mtr -6 -r -c2 ${host}"
    mtr -6 -r -c2 ${host} >> ${OUTFILE} 2>&1
    me "------------\n\n"

    me "### Ping Tests IPv4"
    ping -c ${PCOUNT} -D ${host} >> ${OUTFILE}
    ping -c ${PCOUNT} -D -s 512 ${host} >> ${OUTFILE} 2>&1
    ping -c ${PCOUNT} -D -s 1024 ${host} >> ${OUTFILE} 2>&1
    ping -c ${PCOUNT} -D -s 1452 ${host} >> ${OUTFILE} 2>&1
    me "------------\n\n" >> ${OUTFILE}

    me "## Ping Tests IPv6" >> ${OUTFILE}
    ping6 -n ${PCOUNT} ${host} >> ${OUTFILE} 2>&1
    ping6 -n ${PCOUNT} -s 512 ${host} >> ${OUTFILE} 2>&1
    ping6 -n ${PCOUNT} -s 1024 ${host} >> ${OUTFILE} 2>&1
    ping6 -n ${PCOUNT} -s 1452 ${host} >> ${OUTFILE} 2>&1
    me "####################################################\n\n"
done


END_DATE="$(date +"%Y-%m-%d_%H:%m:%S")"
me "### End script ${END_DATE} ###"
