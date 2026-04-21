# 📄 Mapping các biến trong `config.yml` → Terraform variables

## 1️⃣ Mục đích
`config.yml` (hoặc bất kỳ file YAML/JSON nào) được dùng để chứa **dữ liệu cấu hình** cho toàn bộ hạ tầng. Trong mỗi module Terraform, chúng ta **decode** file này và ánh xạ các trường vào **variables** / **locals** để tạo tài nguyên.

> **Lưu ý:** Tất cả các module trong repo `terraform-module` đều có hai biến chuẩn:
> ```hcl
> variable "config_file"   { type = string }   # tên file YAML được engine truyền vào
> variable "manual_config" { type = map(any); default = {} }   # cho phép ghi đè
> ```

---

## 2️⃣ Cấu trúc mẫu `config.yml`

```yaml
# deployments/dev/infrastructure/config.yml
global:
  environment: dev
  region: us-east-1
  project: SM-Platform
  terraform_state_bucket: sm-terraform-statefile-dev

# ---- Các service -------------------------------------------------
vpc:
  enabled: true
  cidr_block: 10.0.0.0/16
  public_subnets:
    - 10.0.1.0/24
    - 10.0.2.0/24
  private_subnets:
    - 10.0.3.0/24
    - 10.0.4.0/24

dns:
  enabled: true
  domain_name: dev.platform.internal

ecs:
  enabled: true
  cluster_name: dev-core-cluster
  capacity_providers:
    - FARGATE
    - FARGATE_SPOT

service:
  enabled: true
  app_name: customer-api
  service_type: api
  cpu: 256
  memory: 512
  container_port: 8080
  min_capacity: 1
  max_capacity: 3

ecr:
  enabled: true
  repository_names:
    - core-backend-api
    - core-frontend-web

# … các service khác (rds, elasticache, waf, …) được khai báo tương tự
```

> **Điều quan trọng:** Tên **key** (ví dụ `dns`, `ecs`, `service`) chính là **key mới** (canonical). Nếu dự án còn file cũ dùng `route53` hoặc `ecs_cluster`, module sẽ tự **merge** chúng (xem phần 4).

---

## 3️⃣ Bảng ánh xạ (mapping) từ `config.yml` → Terraform

| Module | Key trong `config.yml` | Biến Terraform (local) được tạo | Variable trong `variables.tf` | Ghi chú |
|--------|------------------------|--------------------------------|------------------------------|---------|
| **vpc** | `vpc` | `local.vpc_cfg` | `config_file`, `manual_config` | Dùng `local.vpc_cfg.cidr_block`, `local.vpc_cfg.public_subnets`, … |
| **dns / route53** | `dns` (cũ: `route53`) | `local.dns_cfg` | `config_file`, `manual_config` | `local.dns_cfg.enabled`, `local.dns_cfg.domain_name` |
| **ecs‑cluster** | `ecs` (cũ: `ecs_cluster`) | `local.ecs_cfg` | `config_file`, `manual_config` | `local.ecs_cfg.enabled`, `local.ecs_cfg.cluster_name` |
| **ecs‑service** | `service` (cũ: `ecs_service`) | `local.service_cfg` | `config_file`, `manual_config` | `local.service_cfg.enabled`, `local.service_cfg.app_name`, … |
| **ecr** | `ecr` | `local.ecr_cfg` | `config_file`, `manual_config` | `local.ecr_cfg.repository_names` |
| **alb** | `alb` | `local.alb_cfg` | `config_file`, `manual_config` | `local.alb_cfg.enabled`, `local.alb_cfg.listener_port` |
| **rds** | `rds` | `local.rds_cfg` | `config_file`, `manual_config` | `local.rds_cfg.identifier`, `local.rds_cfg.engine` |
| **elasticache** | `elasticache` | `local.elasticache_cfg` | `config_file`, `manual_config` | `local.elasticache_cfg.cluster_id`, `local.elasticache_cfg.engine` |
| **waf** | `waf` | `local.waf_cfg` | `config_file`, `manual_config` | `local.waf_cfg.enabled`, `local.waf_cfg.name` |
| **kms** | `kms` | `local.kms_cfg` | `config_file`, `manual_config` | `local.kms_cfg.alias`, `local.kms_cfg.enable_key_rotation` |
| **secrets‑manager** | `secrets_manager` | `local.sm_cfg` | `config_file`, `manual_config` | `local.sm_cfg.secret_name`, `local.sm_cfg.enable_rotation` |
| **security‑group** | `security_group` (cũ: `sg`) | `local.sg_cfg` | `config_file`, `manual_config` | `local.sg_cfg.enabled`, `local.sg_cfg.ingress`, `local.sg_cfg.egress` |
| **iam** | `iam` | `local.iam_cfg` | `config_file`, `manual_config` | `local.iam_cfg.create_service_roles`, `local.iam_cfg.managed_policy_arns` |
| **acm** | `acm` | `local.acm_cfg` | `config_file`, `manual_config` | `local.acm_cfg.certificate_domain`, `local.acm_cfg.validation_method` |

> **Cách tạo local trong mỗi module** (được lặp lại trong mọi `locals.tf`):

```hcl
locals {
  # Đường dẫn tới file YAML (được engine truyền vào)
  config_path = "${path.module}/../../../../deployments/${var.env}/infrastructure/${var.config_file}"
  raw_config  = yamldecode(file(local.config_path))

  # Ví dụ cho module ecs‑cluster
  ecs_cfg = merge(
    try(local.raw_config.ecs_cluster, {}),   # legacy
    try(local.raw_config.ecs, {})           # new
  )

  # Áp dụng manual_config nếu muốn ghi đè
  config = merge(local.ecs_cfg, var.manual_config)

  # Các biến dùng trong tài nguyên
  enabled      = try(local.config.enabled, false)
  cluster_name = try(local.config.cluster_name, "")
}
```

---

## 4️⃣ Cách **thêm** một biến mới vào `config.yml`

1. **Cập nhật file YAML** (ví dụ thêm `tags` cho VPC):
   ```yaml
   vpc:
     enabled: true
     cidr_block: 10.0.0.0/16
     tags:
       Owner: "dylan"
       Environment: "dev"
   ```
2. **Mở module tương ứng** (`modules/vpc/locals.tf`) và thêm vào `local.vpc_cfg`:
   ```hcl
   locals {
     # … các dòng hiện có …
     tags = try(local.vpc_cfg.tags, {})
   }
   ```
3. **Sử dụng** trong tài nguyên:
   ```hcl
   resource "aws_vpc" "this" {
     cidr_block = local.cidr_block
     tags       = local.tags
   }
   ```
4. **Nếu muốn cho phép ghi đè qua engine**, chỉ cần truyền `manual_config` khi gọi module:
   ```hcl
   module "vpc" {
     source       = ".../modules/vpc"
     config_file  = "config.yml"
     manual_config = {
       vpc = {
         tags = {
           Owner = "ops-team"
         }
       }
     }
   }
   ```

---

## 5️⃣ Kiểm tra nhanh (sau khi cập nhật)

```bash
# Đảm bảo Terraform có thể đọc file YAML
cd terraform-module
terraform init -backend=false   # (backend tạm thời tắt)
terraform validate               # sẽ báo lỗi nếu key không tồn tại
```

Nếu `terraform validate` chạy thành công → **mapping đã đúng**.

---

## 6️⃣ Kết luận
- **`config.yml`** chứa toàn bộ dữ liệu cấu hình, mỗi **key** tương ứng với một **module**.  
- Các module **decode** file, **merge** key mới + legacy, rồi gán vào **locals** để sử dụng.  
- Biến `config_file` và `manual_config` là giao diện duy nhất giữa engine và các module, giúp việc **thêm / sửa** biến trong `config.yml` trở nên đơn giản và không cần thay đổi mã HCL.

Bạn có thể mở file này tại:
```
/Users/dylan.../terraform-module/config_variables_mapping.md
```
để tham khảo khi cần thêm hoặc chỉnh sửa bất kỳ biến nào trong `config.yml`.
