#cloud-config
hostname: ${hostname}
fqdn: ${fqdn}

write_files:
-   content: |
        # CentOS Atomic Host 7 Storage
        GROWPART=true
        ROOT_SIZE=${root_size}
    path: /etc/sysconfig/docker-storage-setup
    owner: root:root
    permissions: '0644'
