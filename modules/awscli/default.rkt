#lang nisp

(module-file modules awscli
  (desc "awscli")
  (extra-args flakeRoot)
  (lets ([username config.myConfig.modules.users.username]))
  (config-body
    (sops-secret "aws-access-key-id"
      (sopsFile (cat flakeRoot (s "/secrets/aws.yaml")))
      (owner username))
    (sops-secret "aws-secret-access-key"
      (sopsFile (cat flakeRoot (s "/secrets/aws.yaml")))
      (owner username))

    ;; Generate ~/.aws/credentials from decrypted sops secrets
    (sops-template "aws-credentials"
      (content (ms "[default]"
                   "aws_access_key_id = ${config.sops.placeholder.\"aws-access-key-id\"}"
                   "aws_secret_access_key = ${config.sops.placeholder.\"aws-secret-access-key\"}"))
      (owner username)
      (path (s "/home/" username "/.aws/credentials")))

    ;; Default region/output (same dir as credentials, so use sops.templates to avoid permission conflict)
    (sops-template "aws-config"
      (content (ms "[default]"
                   "region = us-east-2"
                   "output = json"))
      (owner username)
      (path (s "/home/" username "/.aws/config")))

    (set environment.systemPackages (with-pkgs awscli2))))
