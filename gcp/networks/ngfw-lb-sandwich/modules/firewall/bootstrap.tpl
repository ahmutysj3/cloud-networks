config sys glo
set hostname ${hostname}
end
config system interface
    edit port1 
        set mode static
        set ip ${port1_ip}/32
        set allowaccess ping https ssh http fgfm
        set description "untrusted"
    next
    edit port2 
        set mode static
        set ip ${port2_ip}/32
        set allowaccess ping https ssh http fgfm
        set description "trusted"
    next
    edit "loopback"
        set vdom "root"
        set ip 192.168.199.1 255.255.255.255
        set allowaccess ping probe-response
        set type loopback
        set role lan
    next
end
config router static
    edit 1
        set gateway ${port1_gateway} 
        set device port1 
    next
    edit 2
        set dst ${port2_gateway}/32
        set device port2
    next
    edit 3
        set dst ${port1_gateway}/32
        set device port1
    next
    edit 4    
       set dst ${trusted_subnet} 
       set gateway ${port2_gateway} 
       set device port2
    next
    edit 5
       set dst ${untrusted_subnet}
       set gateway ${port1_gateway}
       set device port1 
    next
    edit 6
       set dst 35.191.0.0 255.255.0.0
       set gateway ${port2_gateway} 
       set device port2
    next
    edit 7
       set dst 130.211.0.0 255.255.252.0 
       set gateway ${port2_gateway} 
       set device port2       
    next
end
config system vdom-exception
    edit 1
        set object system.interface
    next
end
config firewall vip
    edit "lb-probe"
        set extip ${fgt_public_ip}
        set extintf "port1"
        set portforward enable
        set mappedip "192.168.199.1"
        set extport 8008
        set mappedport 8008
    next
end
config system probe-response
set mode http-probe
end
config firewall service custom
    edit "ProbeService-8008"
        set comment "Default Probe for GCP on port 8008"
        set tcp-portrange 8008
    next
end
config firewall policy
    edit 1
        set name "inet_access"
        set srcintf "port2"
        set dstintf "port1"
        set srcaddr "all"
        set dstaddr "all"
        set action accept
        set schedule "always"
        set service "ALL"
        set nat enable
        set comments "default egress nat policy"
    next
    edit 2
        set name "DefaultGCPProbePolicy"
        set srcintf "port1"
        set dstintf "loopback"
        set srcaddr "all"
        set dstaddr "lb-probe"
        set action accept
        set schedule "always"
        set service "ProbeService-8008"
        set nat enable
        set comments "Default Policy to allow GCP loadbalancer probe traffics on port 8008"
    next
end