# DataWorks Infrastructure - Pipeline Architecture

## CircleCI Pipeline Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              FEATURE BRANCH                                  │
│                         (e.g., feature/my-changes)                          │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      │ git push
                                      ▼
                    ┌──────────────────────────────────┐
                    │   Terraform Validate & Plan      │
                    │        Environment: DEV          │
                    │                                  │
                    │  • terraform fmt                 │
                    │  • terraform validate            │
                    │  • terraform init                │
                    │  • terraform plan                │
                    └──────────────────────────────────┘
                                      │
                                      │ success
                                      ▼
                    ┌──────────────────────────────────┐
                    │      Create Pull Request         │
                    │                                  │
                    │  • Review plan output            │
                    │  • Code review                   │
                    │  • Team approval                 │
                    └──────────────────────────────────┘
                                      │
                                      │ merge to main
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              MAIN BRANCH                                     │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
        ╔═══════════════════════════════════════════════════════════╗
        ║                    DEVELOPMENT ENVIRONMENT                 ║
        ╚═══════════════════════════════════════════════════════════╝
                                      │
                    ┌──────────────────────────────────┐
                    │   Terraform Validate & Plan      │
                    │        Environment: DEV          │
                    │                                  │
                    │  Backend: dataworks-tf-state-dev │
                    │  State Key: dataworks-infra      │
                    └──────────────────────────────────┘
                                      │
                                      │ automatic
                                      ▼
                    ┌──────────────────────────────────┐
                    │      ⏸ MANUAL APPROVAL           │
                    │         (hold-dev)               │
                    │                                  │
                    │  Review plan before apply        │
                    └──────────────────────────────────┘
                                      │
                                      │ approved
                                      ▼
                    ┌──────────────────────────────────┐
                    │    Terraform Apply               │
                    │        Environment: DEV          │
                    │                                  │
                    │  • Create KMS key                │
                    │  • Create 13 S3 buckets          │
                    │  • Apply tags                    │
                    └──────────────────────────────────┘
                                      │
                                      │ success
                                      ▼
        ╔═══════════════════════════════════════════════════════════╗
        ║                     TEST ENVIRONMENT                       ║
        ╚═══════════════════════════════════════════════════════════╝
                                      │
                    ┌──────────────────────────────────┐
                    │   Terraform Validate & Plan      │
                    │        Environment: TEST         │
                    │                                  │
                    │  Backend: dataworks-tf-state-test│
                    │  State Key: dataworks-infra      │
                    └──────────────────────────────────┘
                                      │
                                      │ automatic
                                      ▼
                    ┌──────────────────────────────────┐
                    │      ⏸ MANUAL APPROVAL           │
                    │         (hold-test)              │
                    │                                  │
                    │  Review plan before apply        │
                    └──────────────────────────────────┘
                                      │
                                      │ approved
                                      ▼
                    ┌──────────────────────────────────┐
                    │    Terraform Apply               │
                    │        Environment: TEST         │
                    │                                  │
                    │  • Create KMS key                │
                    │  • Create 13 S3 buckets          │
                    │  • Apply tags                    │
                    └──────────────────────────────────┘
                                      │
                                      │ success
                                      ▼
        ╔═══════════════════════════════════════════════════════════╗
        ║                  PRODUCTION ENVIRONMENT                    ║
        ╚═══════════════════════════════════════════════════════════╝
                                      │
                    ┌──────────────────────────────────┐
                    │   Terraform Validate & Plan      │
                    │        Environment: PROD         │
                    │                                  │
                    │  Backend: dataworks-tf-state-prod│
                    │  State Key: dataworks-infra      │
                    └──────────────────────────────────┘
                                      │
                                      │ automatic
                                      ▼
                    ┌──────────────────────────────────┐
                    │      ⏸ MANUAL APPROVAL           │
                    │         (hold-prod)              │
                    │                                  │
                    │  ⚠️  PRODUCTION - Extra review!   │
                    └──────────────────────────────────┘
                                      │
                                      │ approved
                                      ▼
                    ┌──────────────────────────────────┐
                    │    Terraform Apply               │
                    │        Environment: PROD         │
                    │                                  │
                    │  • Create KMS key                │
                    │  • Create 13 S3 buckets          │
                    │  • Apply tags                    │
                    └──────────────────────────────────┘
                                      │
                                      │ success
                                      ▼
                    ┌──────────────────────────────────┐
                    │    📢 Slack Notification          │
                    │                                  │
                    │  Deployment Complete!            │
                    │  Channel: dataworks-releases     │
                    └──────────────────────────────────┘
```

## Infrastructure Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              AWS ACCOUNT                                     │
│                         (per environment: dev/test/prod)                    │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          TERRAFORM BACKEND                                   │
│                                                                              │
│  ┌────────────────────────┐         ┌────────────────────────┐             │
│  │   S3 Bucket            │         │   DynamoDB Table       │             │
│  │   (State Storage)      │         │   (State Locking)      │             │
│  │                        │         │                        │             │
│  │  dataworks-terraform-  │         │  dataworks-terraform-  │             │
│  │  state-<env>           │         │  state-<env>           │             │
│  │                        │         │                        │             │
│  │  • Versioned           │         │  • LockID: String      │             │
│  │  • Encrypted (AES256)  │         │  • Pay per request     │             │
│  │  • Private             │         │                        │             │
│  └────────────────────────┘         └────────────────────────┘             │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                        INFRASTRUCTURE RESOURCES                              │
│                                                                              │
│  ┌────────────────────────┐                                                 │
│  │   KMS Key              │                                                 │
│  │                        │                                                 │
│  │  • For S3 encryption   │                                                 │
│  │  • Rotation enabled    │                                                 │
│  │  • Alias configured    │                                                 │
│  └────────────────────────┘                                                 │
│                │                                                             │
│                │ encrypts                                                    │
│                ▼                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                          S3 BUCKETS                                  │   │
│  │                                                                      │   │
│  │  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  │   │
│  │  │ Glue Jobs        │  │ Raw Archive      │  │ Raw Zone         │  │   │
│  │  │ - Scripts        │  │ - Archived data  │  │ - Landing data   │  │   │
│  │  │ - Artifacts      │  │ - Lifecycle: 90d │  │ - Lifecycle: 30d │  │   │
│  │  └──────────────────┘  └──────────────────┘  └──────────────────┘  │   │
│  │                                                                      │   │
│  │  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  │   │
│  │  │ Structured Zone  │  │ Curated Zone     │  │ Temp Reload      │  │   │
│  │  │ - Processed data │  │ - Business data  │  │ - Temp storage   │  │   │
│  │  │ - Lifecycle: 180d│  │ - Intelligent    │  │ - Lifecycle: 7d  │  │   │
│  │  └──────────────────┘  └──────────────────┘  └──────────────────┘  │   │
│  │                                                                      │   │
│  │  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  │   │
│  │  │ Domain           │  │ Schema Registry  │  │ Domain Config    │  │   │
│  │  │ - Domain data    │  │ - Schema defs    │  │ - Configuration  │  │   │
│  │  │                  │  │ - Versioned      │  │                  │  │   │
│  │  └──────────────────┘  └──────────────────┘  └──────────────────┘  │   │
│  │                                                                      │   │
│  │  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  │   │
│  │  │ Violation        │  │ Landing Zone     │  │ Landing Process  │  │   │
│  │  │ - Violations     │  │ - File transfer  │  │ - Processing     │  │   │
│  │  │                  │  │                  │  │                  │  │   │
│  │  └──────────────────┘  └──────────────────┘  └──────────────────┘  │   │
│  │                                                                      │   │
│  │  ┌──────────────────┐                                               │   │
│  │  │ Quarantine       │                                               │   │
│  │  │ - Quarantined    │                                               │   │
│  │  │                  │                                               │   │
│  │  └──────────────────┘                                               │   │
│  │                                                                      │   │
│  │  All buckets:                                                        │   │
│  │  • Encrypted with KMS                                                │   │
│  │  • Public access blocked                                             │   │
│  │  • Versioning enabled (where needed)                                 │   │
│  │  • Lifecycle policies configured                                     │   │
│  │  • Tagged with environment, project, owner                           │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                        FUTURE RESOURCES (Commented)                          │
│                                                                              │
│  ┌──────────────────┐  ┌──────────────────┐                                │
│  │ Artifacts Store  │  │ Working Bucket   │                                │
│  │ - Requires Lambda│  │ - Requires vars  │                                │
│  └──────────────────┘  └──────────────────┘                                │
└─────────────────────────────────────────────────────────────────────────────┘
```

## State Management Flow

```
                    Terraform Operation
                           │
                           ▼
              ┌────────────────────────┐
              │   Read State           │
              │   from S3              │
              └────────────────────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │   Acquire Lock         │
              │   from DynamoDB        │
              └────────────────────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │   Execute Changes      │
              │   in AWS               │
              └────────────────────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │   Update State         │
              │   in S3                │
              └────────────────────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │   Release Lock         │
              │   in DynamoDB          │
              └────────────────────────┘
```

## Repository Structure

```
dataworks-infrastructure/
│
├── .circleci/
│   └── config.yml                 ← CircleCI pipeline configuration
│
├── config/
│   ├── dev.tfvars                ← Development variables
│   ├── test.tfvars               ← Test variables
│   └── prod.tfvars               ← Production variables
│
├── modules/
│   ├── s3_bucket/                ← Reusable S3 module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   │
│   ├── secrets_manager/          ← Secrets module
│   ├── compute_node/             ← EC2 module
│   └── glue_database/            ← Glue module
│
├── scripts/
│   └── bootstrap-backend.sh      ← Backend setup automation
│
├── backend.tf                    ← Backend configuration
├── data.tf                       ← Data sources
├── kms.tf                        ← KMS keys
├── locals.tf                     ← Local variables
├── outputs.tf                    ← Output values
├── providers.tf                  ← Provider configuration
├── s3.tf                         ← S3 bucket resources
├── variables.tf                  ← Input variables
│
├── .gitignore                    ← Git ignore patterns
├── Makefile                      ← Helper commands
├── README.md                     ← Main documentation
├── QUICKSTART.md                 ← Quick start guide
├── SETUP_SUMMARY.md              ← Setup documentation
├── CHECKLIST.md                  ← Deployment checklist
├── FILES_SUMMARY.md              ← Files summary
└── ARCHITECTURE.md               ← This file
```

## Deployment Timeline

```
Time    Activity                           Action Required
────────────────────────────────────────────────────────────
Day 1   Setup & Bootstrap                  Manual
        • Run bootstrap scripts            Run scripts
        • Configure CircleCI               Configure settings
        • Test locally                     Run make commands

Day 2   Dev Deployment                     Semi-automated
        • Push to GitHub                   git push
        • Create PR                        Manual approval
        • Merge to main                    Manual approval
        • Deploy to dev                    Manual approval in CircleCI

Day 3   Test Deployment                    Semi-automated
        • Automatic plan                   Automatic
        • Review plan                      Manual review
        • Deploy to test                   Manual approval in CircleCI

Day 4   Production Deployment              Semi-automated
        • Automatic plan                   Automatic
        • Team review                      Manual review
        • Deploy to prod                   Manual approval in CircleCI
        • Verify                           Manual verification

Day 5+  Monitoring & Iteration            Ongoing
        • Monitor resources                Automated
        • Add features                     Development
        • Documentation updates            As needed
```

## Security Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         SECURITY LAYERS                      │
└─────────────────────────────────────────────────────────────┘

Layer 1: IAM & Authentication
├── CircleCI IAM Role (limited permissions)
├── State bucket access control
└── KMS key access policies

Layer 2: Encryption
├── State files encrypted in S3 (AES256)
├── All S3 buckets encrypted (KMS)
└── Secrets encrypted (Secrets Manager)

Layer 3: Network Security
├── Public access blocked on all buckets
├── Bucket policies enforce encryption
└── VPC endpoints (future)

Layer 4: Access Control
├── State locking prevents concurrent changes
├── Manual approvals for deployments
└── Separate environments with separate state

Layer 5: Audit & Monitoring
├── CloudTrail logging (future)
├── S3 access logging (future)
└── State file versioning enabled
```

---

**Document Version**: 1.0  
**Last Updated**: October 20, 2025  
**Maintained by**: DataWorks Team
