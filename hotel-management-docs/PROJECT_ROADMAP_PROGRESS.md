# Tiến Độ Triển Khai Dự Án Mobile App Hotel (Implementation Progress Tracker)
## PRM393 - Hotel Management & Booking Mobile

Tài liệu này dùng để theo dõi **từng bước triển khai (Step-by-Step)** của dự án. Mọi thành viên trong nhóm và AI Assistant sẽ dựa vào đây để biết chính xác:
- Những gì **đã hoàn thành** (kèm file cụ thể).
- Bước **đang thực hiện**.
- Các bước **tiếp theo** cần làm.

---

## 📊 BẢNG TỔNG QUAN TIẾN ĐỘ THEO BƯỚC

| Bước | Hạng Mục / Chức Năng | Nội Dung Chi Tiết | Trạng Thái | File Chính / Thư Mục |
| :---: | :--- | :--- | :---: | :--- |
| **01** | **Repository & Clean Architecture Setup** | Tạo cấu trúc thư mục Clean Architecture, pubspec.yaml, cấu hình Provider, tài liệu hướng dẫn AI | ✅ **HOÀN THÀNH** | `hotel-management-docs/`<br>`hotel_mobile_flutter/` |
| **02** | **Core Foundation & Theme** | Theme Deep Emerald Green `#1B5E4F`, AppColors, DioClient, Storage (Secure + Prefs), Custom Widgets | ✅ **HOÀN THÀNH** | `lib/core/theme/`<br>`lib/core/network/`<br>`lib/core/storage/`<br>`lib/core/widgets/` |
| **03** | **Auth & Login Dashboard** | Domain/Data/Presentation cho Auth, Màn hình Login (Logo HM), Home Dashboard Lễ tân, Mock Fallback | ✅ **HOÀN THÀNH** | `lib/features/auth/`<br>`lib/main.dart` |
| **04** | **Quản Lý Vận Hành Phòng (Room)** | Clean Architecture cho Room, Thẻ RoomCard, Bộ lọc ngang, Tìm kiếm Realtime, Nút Báo dọn/Đã sạch | ✅ **HOÀN THÀNH** | `lib/features/room/` |
| **05** | **Đặt Phòng (Reservation - Booking)** | Form chọn ngày Check-in/Out, validate ngày, tính tổng tiền tự động, tạo đơn đặt phòng mới | ⏳ **TIẾP THEO** | `lib/features/reservation/` |
| **06** | **Danh Sách Đơn Đặt Phòng** | Xem lịch sử đơn đặt (RSV...), bộ lọc trạng thái (Đã xác nhận, Đã nhận phòng, Đã trả phòng) | 📋 Chờ xử lý | `lib/features/reservation/` |
| **07** | **Lưu Trú & Check-in / Check-out (Stay)** | Chuyển đổi từ Đơn đặt sang Lưu trú (Stay), xem chi tiết hóa đơn thanh toán tiền phòng | 📋 Chờ xử lý | `lib/features/stay/` |
| **08** | **Dịch Vụ Khách Sạn (Hotel Services)** | Menu dịch vụ (Ăn uống, Spa, Giặt là), gọi dịch vụ phòng và cộng vào hóa đơn lưu trú | 📋 Chờ xử lý | `lib/features/hotel_service/` |
| **09** | **Nhiệm Vụ Dọn Phòng (Housekeeping Task)** | Màn hình dành riêng cho nhân viên buồng phòng nhận phòng bẩn và bấm hoàn thành | 📋 Chờ xử lý | `lib/features/task/` |
| **10** | **Hồ Sơ & Cài Đặt (Profile & Settings)** | Xem thông tin tài khoản, chuyển đổi Dark/Light mode, Đăng xuất, Lưu trữ cấu hình cục bộ | 📋 Chờ xử lý | `lib/features/profile/` |
| **11** | **Testing & Đóng Gói (APK / Zip Report)** | Kiểm thử validation (50% điểm), viết Báo cáo kỹ thuật PDF (2 trang), build file APK nộp bài | 📋 Chờ xử lý | `test/`, Báo cáo PDF |

---

## 🔍 CHI TIẾT CÁC BƯỚC ĐÃ LÀM XONG

### ✅ Bước 1 & 2: Nền tảng Core & Theme
- [x] Tạo toàn bộ bộ khung Clean Architecture phân tầng: `features/auth`, `room`, `room_type`, `reservation`, `stay`, `hotel_service`, `task`, `profile`.
- [x] Khởi tạo `pubspec.yaml` với thư viện chuẩn môn PRM393: `provider: ^6.1.2`, `dio: ^5.7.0`, `flutter_secure_storage`, `shared_preferences`.
- [x] Cài đặt `AppColors.primary` (`#1B5E4F`) đồng bộ 100% với Web BE.
- [x] Tạo các Widget dùng chung:
  - `CustomButton`: Nút bấm màu xanh ngọc, có spinner loading.
  - `CustomTextField`: Input có nhãn và nút ẩn/hiện mật khẩu.
  - `StatusChip`: Chip trạng thái tròn tự động đổi màu theo nhãn (Sạch, Cần dọn, Hoạt động...).
- [x] Cấu hình `DioClient` tự động chèn header `Authorization: Bearer <token>` và xử lý lỗi 401.

### ✅ Bước 3: Tính năng Xác thực (Auth & Login)
- [x] **Domain:** Entity `UserSession`, Interface `AuthRepository`.
- [x] **Data:** Model `UserSessionModel`, `AuthRemoteDataSource` (gọi BE + Mock Fallback tài khoản `demo.reception / 123456`), `AuthRepositoryImpl`.
- [x] **Presentation:**
  - `AuthProvider`: Quản lý session bằng `ChangeNotifier`, lưu token vào `FlutterSecureStorage`.
  - `LoginPage`: Giao diện bám sát hình ảnh Web (Logo HM nền đen bo góc, form đăng nhập, câu thông báo).
  - `HomePage`: Trang tổng quan hiển thị badge `● Receptionist`, lời chào cá nhân hóa và các lối tắt nghiệp vụ.

### ✅ Bước 4: Vận hành phòng (Room Management)
- [x] **Domain:** Entity `Room` (`roomNumber`, `floor`, `roomTypeName`, `pricePerNight`, `operationalStatus`, `housekeepingStatus`), Interface `RoomRepository`.
- [x] **Data:** `RoomModel` (`.toEntity()`), `RoomRemoteDataSource` (gọi `PRN232.RoomAPI` + Mock 5 phòng `DEV-101`, `DEV-102`, `DEV-201`, `DEV-202`, `DEV-301`), `RoomRepositoryImpl`.
- [x] **Presentation:**
  - `RoomProvider`: Quản lý danh sách phòng, tìm kiếm realtime, lọc theo loại phòng và tình trạng buồng.
  - `RoomCard`: Thẻ phòng mobile hiển thị giá tiền VND, mã phòng, tầng, 2 chip trạng thái và nút bấm thao tác nhanh.
  - `RoomListPage`: Giao diện tra cứu phòng với ô tìm kiếm và 2 hàng thanh ChoiceChip lọc ngang.
  - Liên kết điều hướng từ thẻ *"Vận hành phòng"* trên `HomePage` sang `RoomListPage`.

---

## 🎯 BƯỚC TIẾP THEO: BƯỚC 05 - ĐẶT PHÒNG (RESERVATION / BOOKING)

* **Mục tiêu:** Đáp ứng trọng tâm **50% điểm Business Logic / Rules** theo barem của giảng viên.
* **Nội dung sẽ làm:**
  1. Xây dựng Form Đặt phòng (`BookingPage`):
     - Chọn ngày nhận phòng (Check-in) & ngày trả phòng (Check-out) với date picker.
     - **Business Rules:** Ngày Check-in $\ge$ Hôm nay; Ngày Check-out > Ngày Check-in; Bắt lỗi nếu chọn sai ngày.
     - Nhập thông tin khách hàng: Họ tên, Số điện thoại (Validate 10 chữ số), CCCD/Passport.
     - Tự động tính số đêm và **Tổng tiền thanh toán** (`Số đêm x Giá phòng/đêm`).
  2. Tạo `ReservationProvider`, `ReservationRepository` lưu đơn đặt phòng mới.
  3. Sau khi đặt thành công, tự động cập nhật danh sách đơn và hiển thị thông báo.
