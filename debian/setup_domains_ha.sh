#!/bin/bash
domain_list=$(snow list domains | egrep -v "Domain|------" | gawk '{print $1}')
crm_attribute --type op_defaults --attr-name timeout --attr-value 120s
rm -f pacemaker.cfg
for domain in ${domain_list} do
    echo "primitive $domain ocf:heartbeat:Xen \\
          params xmfile=\"/sNow/snow-tools/etc/domains/$domain.cfg\" \\
          op monitor interval=\"40s\" \\
          meta target-role=\"started\" allow-migrate=\"true\"
         " >> pacemaker.cfg
done
echo commit >> pacemaker.cfg
echo bye >> pacemaker.cfg
crm configure < pacemaker.cfg
