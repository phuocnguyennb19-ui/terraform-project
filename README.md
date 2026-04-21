# Terraform Modules Library

Đây là repository trung tâm chứa các module hạ tầng có thể tái sử dụng (Reusable Modules). Repository này đóng vai trò là **Source Layer** (Lớp nguồn) cho toàn bộ hệ thống IaC.

## 🏗️ Kiến trúc & Liên kết

Repo này không chứa logic triển khai cụ thể cho bất kỳ môi trường nào. Nó chỉ chứa các "khuôn mẫu" (modules). Các repository khác sẽ gọi đến đây để sử dụng code.

### Cách liên kết (Linking)

1. **Base Infrastructure (`base-infras`)**: 
   - Sử dụng các module: `vpc`, `iam`, `dns`, `s3`, `ecr`, `kms`, `waf`.
   - Cấu hình: `source = "git::https://github.com/phuocnguyennb19-ui/terraform-project.git//modules/vpc?ref=master"`

2. **Application Platform (`aws-services-app`)**:
   - Sử dụng các module: `ecs-cluster`, `ecs-service`, `alb`, `rds`, `elasticache`.
   - Cấu hình: `source = "git::https://github.com/phuocnguyennb19-ui/terraform-project.git//modules/ecs-service?ref=master"`

## 📂 Cấu trúc thư mục

- `modules/`: Chứa các module Terraform.
  - `vpc/`: Cấu hình mạng.
  - `ecs-cluster/`: Cấu hình cluster chạy container.
  - `ecs-service/`: Cấu hình dịch vụ ứng dụng.
  - ... (Tổng cộng 15 modules).

## 🚀 Cách sử dụng

Khi tạo một tài nguyên mới, hãy luôn tham chiếu đến module trong repo này thay vì viết code trực tiếp. Điều này đảm bảo tính nhất quán và dễ bảo trì.
