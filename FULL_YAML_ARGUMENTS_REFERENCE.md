# 📖 FULL YAML ARGUMENTS REFERENCE (ECS Centric)

Tài liệu này cung cấp danh sách **đầy đủ** các tham số có thể cấu hình từ file YAML cho hệ sinh thái hạ tầng "Zero-Touch".

---

## 🏗️ 1. VPC Module (Key: `vpc`)
| YAML Key | Kiểu dữ liệu | Mặc định | Mô tả |
|----------|-------------|----------|-------|
| `enabled` | boolean | `false` | Bật/tắt VPC. |
| `cidr` | string | `10.0.0.0/16` | CIDR Block cho VPC. |
| `azs` | list(string) | `[a, b, c]` | Danh sách AZs (vd: `us-east-1a`). |
| `public_subnets` | list(string) | `[]` | Danh sách dải IP Public. |
| `private_subnets` | list(string) | `[]` | Danh sách dải IP Private. |
| `enable_nat_gateway` | boolean | `true` | Có tạo NAT Gateway hay không. |
| `single_nat_gateway` | boolean | `false` | Dùng chung 1 NAT cho tất cả AZ (Tiết kiệm). |
| `public_subnet_tags` | map | `{}` | Tags bổ sung cho Public Subnets. |
| `private_subnet_tags`| map | `{}` | Tags bổ sung cho Private Subnets. |

---

## ⚖️ 2. Application Load Balancer (Key: `alb`) - v9.x Spec
> [!IMPORTANT]
> ALB hỗ trợ cơ chế **Map**, cho phép khai báo đa dạng Listeners và Target Groups.

| YAML Key | Kiểu dữ liệu | Mặc định | Mô tả |
|----------|-------------|----------|-------|
| `enabled` | boolean | `false` | Bật/tắt ALB. |
| `internal` | boolean | `false` | Internal ALB hay Internet-facing. |
| `listeners` | map | `80:HTTP` | Map cấu hình Listeners. |
| `target_groups` | map | `default` | Map cấu hình Target Groups. |
| `security_group_ingress_rules` | map | `{}` | Map cấu hình luật Ingress (tự động tạo SG). |

---

## 🚢 3. ECS Service (Key: `service` hoặc `ecs_service`)
| YAML Key | Kiểu dữ liệu | Mặc định | Mô tả |
|----------|-------------|----------|-------|
| `desired_count` | number | `1` | Số lượng task chạy song song. |
| `task_definition.cpu` | number | `256` | CPU Power (Fargate). |
| `task_definition.memory` | number | `512` | Memory (MB). |
| `container_definitions` | list(map) | `[...]` | Danh sách Container (Image, Port, v.v...). |
| `autoscaling.enabled` | boolean | `false` | Bật tự động giãn nở. |

---

## 🗄️ 4. RDS Database (Key: `rds`)
| YAML Key | Kiểu dữ liệu | Mặc định | Mô tả |
|----------|-------------|----------|-------|
| `engine` | string | `postgres` | Engine DB. |
| `instance_class` | string | `db.t3.micro` | Cấu hình RAM/CPU. |
| `multi_az` | boolean | `false` | Chế độ High Availability. |
| `performance_insights_enabled` | boolean | `false` | Bật Performance Insights. |
| `monitoring_interval` | number | `0` | Enhanced Monitoring (Giây). |

---

## 📁 5. S3 Bucket (Key: `s3`)
| YAML Key | Kiểu dữ liệu | Mặc định | Mô tả |
|----------|-------------|----------|-------|
| `bucket` | string | `unique-name`| Tên Bucket (Global Unique). |
| `versioning_enabled`| boolean | `true` | Lưu trữ các phiên bản của file. |
| `lifecycle_rule` | list(map) | `[]` | Tự động xóa/chuyển vùng dữ liệu cũ. |
| `logging` | map | `{}` | Log truy cập Bucket. |

---

## 🔑 6. IAM (Key: `iam`)
| YAML Key | Kiểu dữ liệu | Mặc định | Mô tả |
|----------|-------------|----------|-------|
| `role_name` | string | `${prefix}-role`| Tên Role. |
| `trusted_role_services`| list | `[...]` | Service được dùng Role. |
| `custom_role_policy_arns`| list | `[]` | Managed Policies gán thêm. |
| `assume_role_policy` | string/map | `null` | Tùy chỉnh Trust Relationship Policy. |

---

## 🖼️ 7. ECR Registry (Key: `ecr`)
| YAML Key | Kiểu dữ liệu | Mặc định | Mô tả |
|----------|-------------|----------|-------|
| `repository_names` | list | `[...]` | Danh sách repos sẽ tạo. |
| `lifecycle_policy` | map/JSON | `null` | Tự động xóa các images cũ (Cleanup rules). |

---

## 🚀 EXAMPLE YAML: ECS FULL SPEC

```yaml
# infrastructure/vpc.yml
vpc:
  enabled: true
  cidr: "10.10.0.0/16"
  public_subnet_tags:
    Tier: "Public"
  private_subnet_tags:
    Tier: "Private"

# services/my-app.yml
app_name: "order-service"
service:
  enabled: true
  desired_count: 2
  port: 8080
  cpu: 512
  memory: 1024
  container_definitions:
    - name: "app"
      image: "123456789.dkr.ecr.us-east-1.amazonaws.com/order:v1.0"
      port_mappings:
        - container_port: 8080
  
  # ALB Integration (V9 Spec)
  alb:
    enabled: true
    security_group_ingress_rules:
      all_http:
        from_port: 80
        to_port: 80
        ip_protocol: "tcp"
        cidr_ipv4: "0.0.0.0/0"
```
