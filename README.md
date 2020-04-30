
Use containerized dell-idrac-adm in order to mount an iso on remote fileserver (http),
and reboot the server from it.

Usage:

docker build -t idrac-racadm .

docker run idrac-racadm -r assisted-lab-3.mgmt.upshift.eng.rdu2.redhat.com -u <USERNAME> -p <PASSWORD> -i http://kvm-01-guest18.lab.eng.rdu2.redhat.com/files/installer-image.iso
