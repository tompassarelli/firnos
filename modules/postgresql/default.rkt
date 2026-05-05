#lang nisp

(module-file modules postgresql
  (desc "PostgreSQL database server for local development")
  (lets ([postgresPackage 'pkgs.unstable.postgresql_18]))
  (config-body
    (set services.postgresql
      (att (enable #t)
           (package 'postgresPackage)
           (authentication
             (call 'pkgs.lib.mkOverride 10
                   (ms "# TYPE  DATABASE        USER            ADDRESS                 METHOD"
                       "local   all             all                                     trust"
                       "host    all             all             127.0.0.1/32            trust"
                       "host    all             all             ::1/128                 trust")))
           (ensureDatabases (lst "postgres"))
           (ensureUsers
             (lst (att (name "postgres")
                       (ensureClauses.superuser #t))))))
    (set environment.systemPackages (lst 'postgresPackage))))
