#lang nisp

(module-file modules printing
  (desc "CUPS printing service with network discovery")
  (config-body
    (service 'printing)
    (service 'avahi
      (att ('nssmdns4 #t)
           ('openFirewall #t)))))
