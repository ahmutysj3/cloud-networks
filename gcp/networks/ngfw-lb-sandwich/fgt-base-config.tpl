config system global
  set hostname ${hostname}
end
config system probe-response
    set mode http-probe
    set http-probe-value OK
    set port ${healthcheck_port}
end
config system dns
  set primary 169.254.169.254
  set protocol cleartext
  unset secondary
end
config system interface
  edit port1
    set mode static
    set ip ${ext_ip}/32
  next
  edit port2
    set mode static
    set allowaccess ping
    set ip ${int_ip}/32
    set secondary-IP enable
    config secondaryip
      edit 0
      set ip ${ilb_ip}/32
      set allowaccess probe-response
      next
    end
  next
  edit port3
    set mode static
    set ip ${mgmt_ip}/32
    set allowaccess ping https ssh fgfm
  next
  edit "probe"
    set vdom "root"
    set ip 169.254.255.100 255.255.255.255
    set allowaccess probe-response
    set type loopback
next
end
config router static
  edit 0
    set device port1
    set gateway ${ext_gw}
  next
  edit 0
    set device port2
    set dst ${int_cidr}
    set gateway ${int_gw}
  next
  edit 0
    set device port2
    set dst 35.191.0.0/16
    set gateway ${int_gw}
  next
  edit 0
    set device port2
    set dst 130.211.0.0/22
    set gateway ${int_gw}
  next
end
