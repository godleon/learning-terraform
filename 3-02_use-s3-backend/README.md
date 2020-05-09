
```bash
$ terraform workspace new example1
$ terraform plan
$ terraform apply -auto-approve

$ terraform workspace new example2
$ terraform plan
$ terraform apply -auto-approve

$ terraform workspace list

$ terraform workspace select example1
$ terraform destroy -auto-approve
```