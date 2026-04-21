# 📄 Mapping Example – Terraform Module Repository

## Mục tiêu
Cung cấp một tài liệu **đơn giản, dễ đọc** mô tả cách ánh xạ (mapping) các trường trong file YAML (hoặc JSON) → **variables** và **locals** của các module Terraform trong repository `terraform-module`.

---

## 1️⃣ Cấu trúc chung của một module
```hcl
# variables.tf
variable "config_file" {
  description = "Tên file YAML/JSON được engine truyền vào"
  type        = string
}

variable "manual_config" {
  description = "Map cấu hình tùy chỉnh để ghi đè (optional)"
  type        = map(any)
  default     = {}
}

# locals.tf (mẫu chung)
locals {
  # Đường dẫn tới file cấu hình
  config_path = "${path.module}/../../../../deployments/${var.env}/infrastructure/${var.config_file}"
  raw_config  = yamldecode(file(local.config_path))

  # Merge key mới + key legacy (nếu có)
  <SERVICE>_cfg = merge(
    try(local.raw_config.<new_key>, {}),
    try(local.raw_config.<legacy_key>, {})
  )

  # Áp dụng manual_config nếu cần
  config = merge(local.<SERVICE>_cfg, var.manual_config)
}
```
---

## 2️⃣ Bảng **mapping** chi tiết (các module hiện có)
| Module | Key mới (new) | Key legacy (cũ) | Đoạn `merge` trong `locals.tf` |
|--------|---------------|-----------------|--------------------------------|
| **ecs‑cluster** | `ecs` | `ecs_cluster` | `ecs_cfg = merge(try(raw_config.ecs_cluster, {}), try(raw_config.ecs, {}))` |
| **ecs‑service** | `service` | `ecs_service` | `service_cfg = merge(try(raw_config.service, {}), try(raw_config.ecs_service, {}))` |
| **route53 / dns** | `dns` | `route53` | `dns_cfg = merge(try(raw_config.dns, {}), try(raw_config.route53, {}))` |
| **security‑group** | `security_group` | `sg` | `sg_cfg = merge(try(raw_config.security_group, {}), try(raw_config.sg, {}))` |
| **vpc** | `vpc` | – | `vpc_cfg = try(raw_config.vpc, {})` |
| **s3** | `s3` | – | `s3_cfg = try(raw_config.s3, {})` |
| **ecr** | `ecr` | – | `ecr_cfg = try(raw_config.ecr, {})` |
| **acm** | `acm` | – | `acm_cfg = try(raw_config.acm, {})` |
| **waf** | `waf` | – | `waf_cfg = try(raw_config.waf, {})` |
| **rds** | `rds` | – | `rds_cfg = try(raw_config.rds, {})` |
| **elasticache** | `elasticache` | – | `elasticache_cfg = try(raw_config.elasticache, {})` |
| **kms** | `kms` | – | `kms_cfg = try(raw_config.kms, {})` |
| **secrets‑manager** | `secrets_manager` | – | `sm_cfg = try(raw_config.secrets_manager, {})` |

---

## 3️⃣ Ví dụ thực tế – Module `ecs-cluster`
### 3.1 `variables.tf`
```hcl
variable "config_file" {
  description = "Tên file YAML/JSON"
  type        = string
}

variable "manual_config" {
  description = "Map ghi đè (optional)"
  type        = map(any)
  default     = {}
}
```

### 3.2 `locals.tf`
```hcl
locals {
  config_path = "${path.module}/../../../../deployments/${var.env}/infrastructure/${var.config_file}"
  raw_config  = yamldecode(file(local.config_path))

  # Merge key mới + legacy
  ecs_cfg = merge(
    try(local.raw_config.ecs_cluster, {}),   # legacy
    try(local.raw_config.ecs, {})           # new
  )

  # Áp dụng manual_config nếu có
  config = merge(local.ecs_cfg, var.manual_config)

  # Các biến dùng trong tài nguyên
  enabled      = try(local.config.enabled, false)
  cluster_name = try(local.config.cluster_name, "")
  capacity_providers = try(local.config.capacity_providers, [])
  default_capacity_provider_strategy = try(local.config.default_capacity_provider_strategy, [])
}
```

### 3.3 `main.tf`
```hcl
resource "aws_ecs_cluster" "this" {
  count = local.enabled ? 1 : 0

  name = local.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  capacity_providers = local.capacity_providers

  dynamic "default_capacity_provider_strategy" {
    for_each = { for i, cp in local.default_capacity_provider_strategy : i => cp }
    content {
      capacity_provider = default_capacity_provider_strategy.value.capacity_provider
      weight            = default_capacity_provider_strategy.value.weight
    }
  }
}
```
---

## 4️⃣ Cách **thêm** một module mới
1. **Tạo file YAML** trong `deployments/<env>/infrastructure/` với key mới (ví dụ `my_service`).
2. **Thêm `variables.tf`** (có `config_file` & `manual_config`).
3. **Thêm `locals.tf`** theo mẫu trên, thay `<SERVICE>` và `<new_key>`/`<legacy_key>` tương ứng.
4. **Sử dụng** các giá trị `local.<service>_cfg.<attribute>` trong tài nguyên.
5. **Cập nhật engine** (`engine/main.tf`) để truyền `config_file = basename(var.config_path)` cho module mới.

---

## 5️⃣ Lưu ý quan trọng
- **Fallback merge** giúp dự án vẫn chạy khi có file cấu hình cũ (key legacy). 
- **manual_config** cho phép ghi đè nhanh trong `engine` mà không cần sửa file YAML.
- **Đảm bảo** mọi module đều có `variable "config_file"` và `variable "manual_config"` để duy trì chuẩn.

---

✅ **Kết luận**: Tài liệu này được đặt trong repository `terraform-module` để mọi thành viên có thể tham khảo nhanh khi thêm hoặc chỉnh sửa mapping. Khi cần cập nhật, chỉ sửa `mapping_example.md` trong cùng thư mục.
