# Provision resources

Data Composer costs a little money as the infrastructure is alive even when no workloads.

To create every thing:
```bash
terraform apply -var 'create_composer_v3=true'
```

To create eveything else except Data Composer:

```bash
terraform apply
```