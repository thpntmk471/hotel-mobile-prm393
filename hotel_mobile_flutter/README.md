# Hotel Management & Booking Mobile - PRM393

Ứng dụng di động **Hotel Management & Booking** dành cho môn học PRM393 (FPT University), kết nối trực tiếp với hệ sinh thái Backend Micro-API của **PRN232 (Hotel Management API)**.

---

## 🏛️ Kiến Trúc Tổng Quan

Dự án áp dụng mô hình **Clean Architecture (Feature-First)** kết hợp với **Riverpod State Management**:

```mermaid
graph TD
    subgraph Presentation Layer
        UI[Pages & Widgets] --> Providers[Riverpod StateNotifier / Notifier]
    end

    subgraph Domain Layer (Pure Dart)
        Providers --> UseCases[Use Cases]
        UseCases --> RepoInterfaces[Repository Interfaces]
        RepoInterfaces -.-> Entities[Entities]
    end

    subgraph Data Layer
        RepoImpl[Repository Implementations] -.->|Implements| RepoInterfaces
        RepoImpl --> DataSources[Remote / Local Data Sources]
        DataSources --> DTOs[Models / DTOs]
        DTOs -->|toEntity()| Entities
        DataSources --> API[PRN232 Micro-APIs via Dio]
    end
```

---

## 📂 Cấu Trúc Thư Mục `lib/`

```text
hotel_mobile_flutter/lib/
├── core/                               # Các thành phần dùng chung toàn ứng dụng
│   ├── constants/                      # Endpoint URLs của 12 Services, Storage Keys, App Colors
│   ├── errors/                         # Xử lý Failure, Exceptions, Network Error Handler
│   ├── network/                        # Cấu hình Dio Client, Auth Interceptor, Retry logic
│   ├── providers/                      # Providers toàn cục (Network, Storage, Theme)
│   ├── routes/                         # Cấu hình GoRouter, AppRoutes, Route Guards (Auth)
│   ├── storage/                        # Secure Storage (JWT Token), SharedPreferences
│   ├── theme/                          # AppTheme, Colors, Typography
│   ├── utils/                          # Format tiền tệ VND/USD, định dạng ngày Check-in/Check-out
│   └── widgets/                        # Common UI (CustomButton, CustomTextField, Loading, RoomCard)
│
└── features/                           # Phân rã theo từng Feature/Microservice nghiệp vụ
    ├── auth/                           # Đăng nhập, lưu session, phân quyền (PRN232.AuthAPI)
    ├── room_type/                      # Danh mục loại phòng: Standard, Deluxe, Suite (PRN232.RoomTypeAPI)
    ├── room/                           # Tìm kiếm phòng trống, chi tiết phòng, giá (PRN232.RoomAPI)
    ├── reservation/                    # Đặt phòng trước, xem danh sách booking (PRN232.ReservationAPI)
    ├── stay/                           # Kỳ lưu trú, Check-in/Check-out, Hóa đơn (PRN232.StayAPI)
    ├── hotel_service/                  # Dịch vụ khách sạn & gọi dịch vụ (PRN232.HotelService & ServiceUsage)
    ├── task/                           # Dành cho Staff: Quản lý công việc dọn phòng/bảo trì (PRN232.TaskAPI)
    └── profile/                        # Thông tin cá nhân khách/nhân viên (PRN232.GuestAPI & StaffAPI)
```

Mỗi Feature trong `features/` đều tuân thủ chuẩn 3 tầng:
* `data/`: `datasources/`, `models/`, `repositories/`
* `domain/`: `entities/`, `repositories/`, `usecases/`
* `presentation/`: `pages/`, `providers/`, `widgets/`

---

## 🚀 Hướng Dẫn Chạy Ứng Dụng

1. Cài đặt các dependencies:
   ```bash
   flutter pub get
   ```
2. Sinh code tự động (Freezed, Riverpod Generator, JSON Serializable):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
3. Chạy ứng dụng trên thiết bị / emulator:
   ```bash
   flutter run
   ```

> [!NOTE]
> Xem thêm tài liệu chi tiết bắt buộc tuân thủ:
> - [developer_guide.md](file:///d:/project_prm/hotel-management-docs/developer_guide.md): Hướng dẫn kiến trúc, coding standards cho lập trình viên & AI.
> - [hotel_booking_flow_guide.md](file:///d:/project_prm/hotel-management-docs/hotel_booking_flow_guide.md): Luồng dữ liệu chi tiết từ Backend Services sang Flutter UI.

