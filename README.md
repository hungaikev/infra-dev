# Terraform Infra

Generate Key 

```bash
ssh-keygen -f staging_key 

```

```bash
chmod 400 staging_key.pub 

ssh-add -K staging_key 

ssh -A ubuntu@bastion-host-ip

```
