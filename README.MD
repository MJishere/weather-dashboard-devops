######################################################################
Inrastructure Pipeline
######################################################################
                   ┌─────────────────────┐
                   │     Jenkins EC2     │
                   │  (Docker + Terraform│
                   │   + kubectl + git)  │
                   └─────────┬───────────┘
           ------------------│------------------
           │                 │                 │
           ▼                 ▼                 ▼
   ┌─────────────┐   ┌─────────────┐   ┌──────────────┐
   │ Checkout    │   │ Terraform   │   │ Manual       │
   │ SCM repo    │   │ Init & Plan │   │ Approval     │
   │ (infra/)    │   │ - terraform │   │ (input step) │
   │             │   │   init      │   │              │
   │             │   │ - terraform │   │              │
   │             │   │   plan      │   │              │
   └─────────────┘   └─────────────┘   └──────────────┘
           │                 │                 │
           └--------┬--------┴--------┬--------┘
                    ▼                 ▼
            ┌───────────────────────────┐
            │ Terraform Apply (tfplan)  │
            │ - Creates/updates AWS VPC │
            │ - Creates EKS Cluster     │
            │ - Creates ECR Repos       │
            └─────────────┬─────────────┘
                          ▼
                 ┌───────────────────┐
                 │ AWS Infrastructure│
                 │ - VPC             │
                 │ - Subnets         │
                 │ - EKS Cluster     │
                 │ - ECR Repositories│
                 └───────────────────┘
