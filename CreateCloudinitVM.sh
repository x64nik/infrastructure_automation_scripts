

#!/bin/bash 

###################################################################
#       Script Name        :                                                                                                                     
#       Description        :                                                                                 
#       Args           :                                                                                           
#       Author         : x64nik                                                
#       Github         : https://github.com/x64nik                       
###################################################################

read -e -p "QCOW2 Path: " qcow_image
read -p "VMid: " vm_id
read -p "VM_Name: " vm_name
read -p "Cores: " cores
read -p "Memory [default: 512]: " memory
memory=${memory:-512}
read -p "username: " username

read -s -p "password: " password
echo " "
read -s -p "confirm password: " Cpassword
echo " "

if [[ "$password" != "$Cpassword" ]];
then
    echo "password didnt match"
    exit 0
fi

read -p "IP/CIDR: " ip_addr
read -p "Gateway: [default: 192.168.0.1]: " gateway
gateway=${gateway:-192.168.0.1}
read -p "Nameserver [default: 1.1.1.1]: " nameserver
nameserver=${nameserver:-1.1.1.1}
read -p "Searchdomain [default: homelab.local]: " searchdomain
searchdomain=${searchdomain:-homelab.local}
read -p "Disk_Size [default: 10GB]: " disk_size
disk_size=${disk_size:-10}

if [[ -z $qcow_image || -z $vm_id || -z $vm_name || -z $cores || -z $username || -z $password || -z $ip_addr || -z $nameserver ]]; then
    echo "one or more userinput are empty"
    echo "make sure you enter all values correctly"
    exit 0
fi

create_vm="qm create $vm_id -name $vm_name --sockets 1 --cores $cores --memory $memory --ostype l26 --storage local"
set_vm_cloudinit="qm set $vm_id --ide1 local:cloudinit"
import_disk="qm importdisk $vm_id $qcow_image local"
config_cloudinit="qm set $vm_id --scsi0 local:$vm_id/vm-$vm_id-disk-0.raw,discard=on --scsihw virtio-scsi-single --net0 model=virtio,bridge=vmbr0 --boot order=scsi0 --agent enabled=1 --ciuser=$username --cipassword=$password --ipconfig0 ip=$ip_addr,gw=$gateway --nameserver=$nameserver --searchdomain=$searchdomain"
resize_disk="qm resize $vm_id scsi0 +$disk_size""G"
cloudinit_config_update="qm cloudinit update $vm_id"
start_vm="qm start $vm_id"

echo " "
echo " "
echo "$create_vm"
echo "$set_vm_cloudinit"
echo "$import_disk"
echo "$config_cloudinit"
echo "$resize_disk"
echo "$cloudinit_config_update"
echo "$start_vm"
echo " "
echo " "

$create_vm
$set_vm_cloudinit
$import_disk
$config_cloudinit
$resize_disk
$cloudinit_config_update
$start_vm


