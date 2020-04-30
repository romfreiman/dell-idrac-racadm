#!/usr/bin/env bash
set -euoE pipefail

usage() 	{
	echo "${@}"
	echo "Usage: $0 -r idrac-hostname -u user -p password -i http://iso-url" 1>&2; 
	exit 1; 
}

if [[ $# -ne 8 ]]; then
	usage "Insufficinet number of parameters"
fi

while getopts ":r:u:p:i:" o; do
	case "${o}" in
		r)
			HOST=${OPTARG};;
		u)
			USER=${OPTARG};;
		p)
			PASSWORD=${OPTARG};;
		i)
			ISO_URL=${OPTARG}
			[[ $ISO_URL =~ http://.* ]] || usage "Iso should be with http prefix"
			;;
		*)
			usage;;
	esac
done
shift $((OPTIND-1))

echo HOST = $HOST
echo USER = $USER
echo PASSWORD = $PASSWORD
echo ISO_URL = $ISO_URL

if ! curl --output /dev/null --silent --head --fail "$ISO_URL"; then
	  usage "******* ISO does not exist in the provided url: $ISO_URL"
fi

echo '******* Disconnecting existing image (just in case)'
/opt/dell/srvadmin/bin/idracadm7 -r $HOST -u $USER -p $PASSWORD remoteimage -d

echo '******* Showing idrac remoteimage status'
/opt/dell/srvadmin/bin/idracadm7 -r $HOST -u $USER -p $PASSWORD remoteimage -s


echo "******* Connecting remote iso $ISO_URL to boot from"
/opt/dell/srvadmin/bin/idracadm7 -r $HOST -u $USER -p $PASSWORD remoteimage -c -l $ISO_URL

echo '******* Showing idrac remoteimage status'
/opt/dell/srvadmin/bin/idracadm7 -r $HOST -u $USER -p $PASSWORD remoteimage -s

if ! /opt/dell/srvadmin/bin/idracadm7 -r $HOST -u $USER -p $PASSWORD remoteimage -s | grep $ISO_URL; then
	usage 'ISO was not configured correctly'
fi

echo '******* Setting idrac to boot once from the attached iso'
/opt/dell/srvadmin/bin/idracadm7 -r assisted-lab-1.mgmt.upshift.eng.rdu2.redhat.com -u admin -p et-o3xaeC7oe set iDRAC.VirtualMedia.BootOnce 1
/opt/dell/srvadmin/bin/idracadm7 -r assisted-lab-1.mgmt.upshift.eng.rdu2.redhat.com -u admin -p et-o3xaeC7oe set iDRAC.ServerBoot.FirstBootDevice VCD-DVD

echo '******* Rebooting the server'
/opt/dell/srvadmin/bin/idracadm7 -r assisted-lab-1.mgmt.upshift.eng.rdu2.redhat.com -u admin -p et-o3xaeC7oe serveraction powercycle

echo '******* Done'
