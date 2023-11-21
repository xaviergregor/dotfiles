#! /bin/bash
# Patch du fichier JS
sed -i.bak "s/.data.status.toLowerCase() !== 'active') {/.data.status.toLowerCase() !== 'active') { orig_cmd\(\); } else if ( false ) {/" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
# Restart PVE Web
systemctl restart pveproxy.service
# Restart PBS Web
#systemctl restart proxmox-backup-proxy.service
