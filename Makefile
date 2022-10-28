plan:
	terraform init
	terraform fmt
	terraform validate
	terraform plan -var-file=variables.tfvars -out plan.tfplan

apply:
	terraform apply plan.tfplan