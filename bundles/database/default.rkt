#lang nisp

(bundle-file database
  (desc "database tools")
  (sub-modules 'dbeaver 'sqlite 'postgresql 'freetds))
