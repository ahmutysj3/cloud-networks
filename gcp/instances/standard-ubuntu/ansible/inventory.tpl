---
primary:
    hosts:
        ubuntu-1:
            ansible_host: ${host_1}
        ubuntu-2:
            ansible_host: ${host_2}

backup:
    hosts:
        ubuntu-3:
            ansible_host: ${host_3}

ubuntu:
    children:
        primary:
        backup:

    vars:
        ansible_user: ubuntu
        ansible_ssh_private_key_file: ~/.ssh/id_rsa
        