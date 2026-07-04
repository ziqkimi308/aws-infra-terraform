# P3 – Terraform AWS Infrastructure Provisioning

## Overview
Provisions a basic multi-tier AWS environment — VPC, public subnet, security group, key pair, and EC2 instance running Apache — using Terraform. Recreated from scratch as a repetition exercise following P1's manual/console-based build.

## Architecture
- **VPC** (`10.0.0.0/16`) with DNS support/hostnames enabled
- **Public subnet** (`10.0.1.0/24`) with auto-assign public IP
- **Internet Gateway** + public route table (routes `0.0.0.0/0` to IGW)
- **Security group** allowing inbound SSH (22) and HTTP (80) from anywhere, all outbound
- **Key pair** imported from local public key
- **EC2 instance** (t3.micro) with user_data bootstrapping Apache on boot

## Tech Stack
- Terraform (AWS provider)
- AWS: VPC, Subnet, Internet Gateway, Route Table, Security Group, Key Pair, EC2
- Apache2 (installed via user_data)

## Project Structure
```
p3-terraform/
├── main.tf                      # Root resources: SG, key pair, EC2
├── variables.tf                 # Input variables
├── outputs.tf                   # Output values
├── providers.tf                 # Provider configuration
├── modules/
│   └── vpc/                     # VPC, subnet, IGW, route table module
├── terraform.tfvars.example     # Sample variables (copy to terraform.tfvars and fill in)
└── README.md
```

## How to Run
```bash
# Clone and enter the project
git clone <repo-url>
cd p3-terraform

# Copy example vars and fill in your own values
cp terraform.tfvars.example terraform.tfvars

# Initialize, plan, apply
terraform init
terraform plan
terraform apply

# Check outputs anytime
terraform output

# Tear down when done
terraform destroy
```

## Problems Faced & Fixes

**Issue:** Website returned `ERR_CONNECTION_TIMED_OUT` — Apache never started.
**Investigation:** Security group was correctly attached (`tf-devops-ec2-sg`, not default) with port 80 open, ruling out network config. SSH into the instance showed `apache2.service could not be found`.
**Root cause:** `sudo cloud-init status` showed `status: error`, and `/var/log/cloud-init-output.log` showed the `cc_scripts_user` module failed. Mixed tabs/spaces inside the Terraform `<<-EOF` heredoc corrupted the shebang line, so the user_data script never executed.
**Fix:** Removed all leading whitespace from heredoc lines in `user_data`. Recreated the instance (`terraform destroy` → `terraform apply`) to pick up the corrected script. Verified with `curl` and browser — Apache served the page correctly on the new IP.

## Screenshots

| # | Description | File |
|---|---|---|
| 1 | Terraform installed & version check | `screenshots/download-terraform.png`, `screenshots/verify-terraform-installed.png` |
| 2 | `terraform init` | `screenshots/terraform_init.png` |
| 3 | `terraform plan` output | `screenshots/terraform_plan.png` |
| 4 | `terraform apply` (first run) | `screenshots/terraform_apply.png` |
| 5 | Website error — connection timed out | `screenshots/website_error.png` |
| 6 | Troubleshooting the site error (SG check, SSH, cloud-init logs) | `screenshots/troubleshoot_website_error_1.png`, `screenshots/troubleshoot_website_error_2.png` |
| 7 | Fix applied, re-ran apply | `screenshots/make_changes_reapply.png`, `screenshots/terraform_apply_2.png` |
| 8 | EC2 instance running in console | `screenshots/ec2_running.png` |
| 9 | Website working — Apache serving page | `screenshots/website_working_result.png` |
| 10 | `terraform output` command & result | `screenshots/terraform_output_command.png`, `screenshots/terraform_output.png` |
| 11 | `terraform state list` / `terraform state show` | `screenshots/terraform_state_list.png`, `screenshots/terraform_state_show.png` |
| 12 | `terraform destroy` (teardown) | `screenshots/terraform_destroy.png`, `screenshots/terraform_destroy_2.png` |

## Notes
- State files and real `.tfvars` are excluded from this repo via `.gitignore` — see `terraform.tfvars.example` for the variable structure.
- Instance was recreated fresh for this project (per personal practice policy of not reusing prior infra).
- Never edit `terraform.tfstate` by hand — use `terraform state` subcommands (`list`, `show`, `mv`, `rm`) instead.