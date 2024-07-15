---
ubuntu:
    hosts:
        ubuntu-1:
            ansible_host: ${host_1}
        ubuntu-2:
            ansible_host: ${host_2}

    vars:
        ansible_user: ubuntu
        ansible_ssh_private_key_file: ~/.ssh/id_rsa

all:
    vars:
        host_key_checking: false
        