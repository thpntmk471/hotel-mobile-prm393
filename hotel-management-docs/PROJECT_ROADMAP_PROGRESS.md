# Tiến Độ Triển Khai Dự Án Mobile App Hotel (Implementation Progress Tracker)
## PRM393 - Hotel Management & Booking Mobile

Tài liệu này dùng để theo dõi **từng bước triển khai (Step-by-Step)** của dự án. Mọi thành viên trong nhóm và AI Assistant sẽ dựa vào đây để biết chính xác:
- Những gì **đã hoàn thành** (kèm file cụ thể).
- Toàn bộ 10 bước lập trình ứng dụng đã hoàn thành 100%.

---

## 📊 BẢNG TỔNG QUAN TIẾN ĐỘ THEO BƯỚC

| Bước | Hạng Mục / Chức Năng | Nội Dung Chi Tiết | Trạng Thái | File Chính / Thư Mục |
| :---: | :--- | :--- | :---: | :--- |
| **01** | **Repository & Clean Architecture Setup** | Cấu trúc thư mục Clean Architecture, pubspec.yaml, cấu hình Provider, tài liệu hướng dẫn AI | ✅ **HOÀN THÀNH** | `hotel-management-docs/`<br>`hotel_mobile_flutter/` |
| **02** | **Core Foundation & Theme** | Theme Deep Emerald Green `#1B5E4F`, AppColors, DioClient, Storage (Secure + Prefs), Custom Widgets | ✅ **HOÀN THÀNH** | `lib/core/theme/`<br>`lib/core/network/`<br>`lib/core/storage/`<br>`lib/core/widgets/` |
| **03** | **Auth & Login Dashboard** | Domain/Data/Presentation cho Auth, Màn hình Login (Logo HM), Home Dashboard Lễ tân, Mock Fallback | ✅ **HOÀN THÀNH** | `lib/features/auth/`<br>`lib/main.dart` |
| **04** | **Quản Lý Vận Hành Phòng (Room)** | Clean Architecture cho Room, Thẻ RoomCard, Bộ lọc ngang, Tìm kiếm Realtime, Nút Báo dọn/Đã sạch | ✅ **HOÀN THÀNH** | `lib/features/room/` |
| **05** | **Đặt Phòng (Reservation - Booking)** | Form chọn ngày Check-in/Out, validate ngày, tính tổng tiền tự động, tạo đơn đặt phòng mới | ✅ **HOÀN THÀNH** | `lib/features/reservation/` |
| **06** | **Danh Sách Đơn Đặt Phòng** | Xem lịch sử đơn đặt (RSV...), bộ lọc trạng thái (Đã xác nhận, Đã nhận phòng, Đã trả phòng), Check-in/Out nhanh | ✅ **HOÀN THÀNH** | `lib/features/reservation/` |
| **07** | **Lưu Trú & Check-in / Check-out (Stay)** | Chuyển đổi từ Đơn đặt sang Lưu trú (Stay), xem chi tiết hóa đơn thanh toán tiền phòng | ✅ **HOÀN THÀNH** | `lib/features/stay/` |
| **08** | **Dịch Vụ Khách Sạn (Hotel Services)** | Menu dịch vụ (Ăn uống, Spa, Giặt là), gọi dịch vụ phòng và cộng vào hóa đơn lưu trú | ✅ **HOÀN THÀNH** | `lib/features/hotel_service/` |
| **09** | **Nhiệm Vụ Dọn Phòng (Housekeeping Task)** | Màn hình dành riêng cho nhân viên buồng phòng nhận nhiệm vụ, lọc tầng, nhận phòng & bấm hoàn thành | ✅ **HOÀN THÀNH** | `lib/features/task/` |
| **10** | **Hồ Sơ & Cài Đặt (Profile & Settings)** | Xem thông tin tài khoản, chuyển đổi Dark/Light mode thời gian thực, Đăng xuất, cấu hình cục bộ | ✅ **HOÀN THÀNH** | `lib/features/profile/` |
| **11** | **Testing & Đóng Gói (APK / Zip Report)** | Báo cáo kỹ thuật PDF & đóng gói APK nộp bài | ⏸️ **TẠM BỎ QUA** *(Theo yêu cầu tập trung code)* | `test/`, Báo cáo PDF |

---

## 🔍 CHI TIẾT CÁC BƯỚC ĐÃ LÀM XONG

### ✅ Bước 1 & 2: Nền tảng Core & Theme
- [x] Tạo toàn bộ bộ khung Clean Architecture phân tầng: `features/auth`, `room`, `room_type`, `reservation`, `stay`, `hotel_service`, `task`, `profile`.
- [x] Khởi tạo `pubspec.yaml` với thư viện chuẩn môn PRM393: `provider: ^6.1.2`, `dio: ^5.7.0`, `flutter_secure_storage`, `shared_preferences`.
- [x] Cài đặt `AppColors.primary` (`#1B5E4F`) đồng bộ 100% với Web BE.
- [x] Tạo các Widget dùng chung: `CustomButton`, `CustomTextField`, `StatusChip`.
- [x] Cấu hình `DioClient` tự động chèn header `Authorization: Bearer <token>` và xử lý lỗi 401.

### ✅ Bước 3: Tính năng Xác thực (Auth & Login)
- [x] **Domain:** Entity `UserSession`, Interface `AuthRepository`.
- [x] **Data:** Model `UserSessionModel`, `AuthRemoteDataSource` (gọi BE + Mock Fallback tài khoản `demo.reception / 123456`, `demo.admin`, `demo.housekeeping`), `AuthRepositoryImpl`.
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

### ✅ Bước 5 & 6: Đặt Phòng & Danh Sách Đơn (Reservation & Booking)
- [x] **Domain:** Entity `Reservation`, Interface `ReservationRepository`.
- [x] **Data:** `ReservationModel`, `ReservationRemoteDataSource`, `ReservationRepositoryImpl`.
- [x] **Presentation:**
  - `ReservationProvider`: Xử lý tạo đơn đặt phòng mới, lọc theo trạng thái (`Tất cả`, `Đã xác nhận`, `Đã nhận phòng`, `Đã trả phòng`).
  - `BookingPage`: Form đặt phòng kiểm tra ngày Check-out > Check-in >= hôm nay, validate SĐT 10 số, tự động tính tổng tiền theo số đêm.
  - `ReservationListPage`: Danh sách đơn đặt dạng thẻ Card với hành động Nhận phòng (Check-in) nhanh.

### ✅ Bước 7: Quản Lý Lưu Trú & Hóa Đơn (Stay & Invoices)
- [x] **Domain:** Entity `Stay`, `InvoiceLine`, Interface `StayRepository`.
- [x] **Data:** `StayModel`, `StayRemoteDataSource`, `StayRepositoryImpl`.
- [x] **Presentation:**
  - `StayProvider`: Quản lý danh sách khách đang lưu trú, xử lý trả phòng (Check-out) và thanh toán.
  - `StayListPage`: Danh sách thẻ khách đang lưu trú, thời gian check-in/out thực tế, tổng hóa đơn.
  - `StayDetailPage`: Chi tiết hóa đơn phòng + dịch vụ, modal thanh toán hỗ trợ Tiền mặt, VNPay QR Code và Thẻ tín dụng.

### ✅ Bước 8: Dịch Vụ Khách Sạn (Hotel Services)
- [x] **Domain:** Entity `HotelServiceItem`, `ServiceUsageOrder`, Interface `HotelServiceRepository`.
- [x] **Data:** `HotelServiceModel`, `HotelServiceRemoteDataSource`, `HotelServiceRepositoryImpl`.
- [x] **Presentation:**
  - `HotelServiceProvider`: Danh mục dịch vụ phân loại theo Ăn uống (F&B), Giặt ủi, Spa Massage, Xe đưa đón.
  - `ServiceCatalogPage`: Menu sản phẩm dịch vụ dạng thẻ Card, hộp thoại Gọi dịch vụ tận phòng (chọn phòng, số lượng, tự động tính thành tiền).

### ✅ Bước 9: Quản Lý Buồng Phòng & Công Việc (Housekeeping Task)
- [x] **Domain:** Entity `HousekeepingTask`, Interface `TaskRepository`.
- [x] **Data:** `HousekeepingTaskModel`, `TaskRemoteDataSource`, `TaskRepositoryImpl`.
- [x] **Presentation:**
  - `TaskProvider`: Lọc theo trạng thái (`Chờ nhận`, `Đang dọn`, `Hoàn thành`) và tầng.
  - `TaskListPage`: Thẻ tác vụ phân loại mức độ ưu tiên (`Cao`, `Trung bình`, `Thấp`), nút bấm "Nhận dọn phòng" và "Xác nhận dọn sạch" tự động đồng bộ sang trạng thái phòng sạch.

### ✅ Bước 10: Hồ Sơ & Cài Đặt (Profile & Settings)
- [x] **Domain:** Entity `UserProfile`, Interface `ProfileRepository`.
- [x] **Data:** `UserProfileModel`, `ProfileLocalDataSource`, `ProfileRepositoryImpl`.
- [x] **Presentation:**
  - `ProfileProvider`: Quản lý hồ sơ nhân viên, chế độ Dark/Light mode được lưu trữ qua `SharedPreferences`.
  - `ProfilePage`: Màn hình hồ sơ chuyên nghiệp với Avatar, Badge chức vụ, ca trực, công tắc chuyển đổi Chế độ tối (Dark Mode) thời gian thực trên toàn ứng dụng, quản lý thông báo, cập nhật thông tin cá nhân và nút Đăng xuất an toàn.
  - Tích hợp lối tắt trên `AppBar` và Card hành động ở `HomePage`.
