config sys glo
set hostname ${hostname}
end
config system interface
    edit port1 
        set mode static
        set type physical
        set ip ${port1_ip}/32
        set allowaccess ping
        set description "untrusted"
    next
    edit port2 
        set mode static
        set type physical
        set ip ${port2_ip}/32
        set allowaccess ping
        set description "trusted"
        config secondaryip
            edit 0
                set ip ${ilb_ip}/32
                set allowaccess probe-response
            next
        end
    next
    edit "probe"
        set vdom "root"
        set ip 169.254.255.100 255.255.255.255
        set allowaccess probe-response https
        set type loopback
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
    edit 8
        set dst ${protected_subnet}
        set gateway ${port2_gateway}
        set device port2
    next
end
config firewall ippool
    edit "elb-eip"
        set startip ${elb_ip}
        set endip ${elb_ip}
    next
end
config firewall vip
    edit "probe-vip"
        set extip ${elb_ip}
        set mappedip "169.254.255.100"
        set extintf "port1"
        set portforward enable
        set extport ${hc_port}
        set mappedport ${hc_port}
    next
    edit "mgmt-vip"
        set extip ${elb_ip}
        set mappedip "169.254.255.100"
        set extintf "port1"
        set portforward enable
        set extport 443
        set mappedport 443
end
config system probe-response
    set mode http-probe
    set http-probe-value OK
    set port ${hc_port}
end
config firewall service custom
    edit "ProbeService-${hc_port}"
        set comment "Default Probe for GCP on port ${hc_port}"
        set tcp-portrange ${hc_port}
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
        set logtraffic all
        set utm-status enable
        set ippool enable 
        set poolname "elb-eip"
        set comments "default egress nat policy"
    next
    edit 2
        set name "allow-probe-vip"
        set srcintf "port1"
        set dstintf "probe"
        set action accept
        set srcaddr "all"
        set dstaddr "probe-vip"
        set schedule "always"
        set service "ProbeService-${hc_port}"
    next
    edit 3
        set name "allow-mgmt-vip"
        set srcintf "port1"
        set dstintf "probe"
        set action accept
        set srcaddr "all"
        set dstaddr "mgmt-vip"
        set schedule "always"
        set service "HTTPS"
    next
end

