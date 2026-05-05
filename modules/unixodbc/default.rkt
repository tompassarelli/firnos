#lang nisp

(module-file modules unixodbc
  (desc "unixODBC with MSSQL driver")
  (lets ([msodbcsql18 'pkgs.unstable.unixodbcDrivers.msodbcsql18]))
  (config-body
    (set 'environment.systemPackages
      (lst 'pkgs.unixODBC 'msodbcsql18))

    (set 'environment.variables
      (att ('ODBCSYSINI "/etc")
           ('ODBCINI "/etc/odbc.ini")))

    (set 'environment.etc
      (att ("${\"odbcinst.ini\"}"
            (att ('text
                  (ms "[ODBC Driver 18 for SQL Server]"
                      "Description = Microsoft ODBC Driver 18 for SQL Server"
                      "Driver = ${msodbcsql18}/lib/libmsodbcsql-18.1.so.1.1"))))
           ("${\"odbc.ini\"}"
            (att ('text
                  (ms "[msa_data]"
                      "Driver = ODBC Driver 18 for SQL Server"
                      "Server = localhost"
                      "Database = msa_data"
                      "TrustServerCertificate = Yes"))))))))
