# VARIABLES_MAPPING_GUIDE – terraform‑module

## Overview
All modules in this repo share a **standard mapping pattern**:

| File | Purpose |
|------|---------|
| `variables.tf` | Declares two universal inputs: `config_file` (string) and `manual_config` (map). |
| `locals.tf`   | Loads the YAML file passed by the engine, merges legacy & new keys, and creates a `local.<service>_cfg` map that the resources consume. |

### Adding a New Variable

1. **Update the service YAML** (e.g. `apps.yml` in `aws-application-infras/deployments/<env>/services/`).
   ```yaml
   service:
     # existing keys …
     new_key: "value"          # ← add here, keep 2‑space indentation
   ```

2. **Expose the key in the module** (`modules/ecs-service/locals.tf`):
   ```hcl
   locals {
     # existing locals …
     new_key = try(local.raw_config.service.new_key, null)   # default null
   }
   ```

3. **Consume the variable** in `modules/ecs-service/main.tf` (or any resource file):
   ```hcl
   resource "aws_ecs_task_definition" "this" {
     # …
     # Example usage of the new key
     execution_role_arn = local.new_key != null ? local.new_key : aws_iam_role.default.arn
   }
   ```

4. **Optional – allow overrides from the engine**
   The `manual_config` variable already merges with the YAML map, so you can pass:
   ```hcl
   module "ecs_service" {
     source       = ".../modules/ecs-service"
     config_file  = "apps.yml"
     manual_config = {
       service = {
         new_key = "override‑value"
       }
     }
   }
   ```

### Legacy Key Support
If you need to keep an old key name (e.g., `ecs_service`), simply add it to the merge block:

```hcl
service_cfg = merge(
  try(local.raw_config.service, {}),
  try(local.raw_config.ecs_service, {})   # legacy
)
```

No further code changes are required.

### Quick Validation

```bash
cd terraform-module
terraform init -backend=false
terraform validate   # should succeed if the key exists in the YAML
```

---

**Result:** After following the steps, the new variable is available to the module without touching any other part of the codebase.
