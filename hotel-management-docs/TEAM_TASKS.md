# Kế Hoạch Phân Chia Công Việc Phát Triển Mobile App Khách Sạn (Hotel Mobile PRM393)

Bảng phân chia công việc chuẩn mực cho các thành viên trong nhóm phát triển dự án di động **PRM393** (Hotel Booking & Management) kết nối Backend **PRN232 Micro-APIs**.

---

## 👥 PHÂN CHIA NHIỆM VỤ THEO TÍNH NĂNG (FEATURE MATRIX)

| Mã CV | Tính năng / Phân hệ | Nhiệm vụ chi tiết | Thành viên phụ trách | Trạng thái |
| :--- | :--- | :--- | :--- | :--- |
| **CORE-01** | **Core Architecture & Setup** | Cấu hình Dio, Interceptor, Riverpod, Secure Storage, Routes | Lead / Thành viên 1 | [x] Sẵn sàng khung |
| **FEAT-01** | **Xác thực (Auth)** | Đăng nhập/Đăng ký tài khoản, Quản lý Token JWT & Session | Thành viên 1 | [ ] Đang tiến hành |
| **FEAT-02** | **Danh mục loại phòng (RoomType)**| Hiển thị danh mục loại phòng (Standard, Deluxe, Suite, VIP) | Thành viên 2 | [ ] Chờ xử lý |
| **FEAT-03** | **Danh sách & Chi tiết phòng (Room)** | Tìm kiếm phòng, lọc theo ngày, trạng thái phòng trống, xem chi tiết | Thành viên 2 | [ ] Chờ xử lý |
| **FEAT-04** | **Đặt phòng (Reservation)** | Chọn phòng, điền thông tin khách, tạo đơn đặt phòng, xem lịch sử đặt | Thành viên 3 | [ ] Chờ xử lý |
| **FEAT-05** | **Quản lý lưu trú (Stay & Invoice)** | Check-in, Check-out, xem hóa đơn tiền phòng và thanh toán | Thành viên 3 | [ ] Chờ xử lý |
| **FEAT-06** | **Dịch vụ khách sạn (Hotel Services)**| Xem menu dịch vụ (Spa, Gym, F&B), gọi dịch vụ phòng (ServiceUsage) | Thành viên 4 | [ ] Chờ xử lý |
| **FEAT-07** | **Quản lý công việc (Housekeeping Task)**| Xem danh sách phòng cần dọn, nhận việc và hoàn thành dọn phòng | Thành viên 4 | [ ] Chờ xử lý |
| **FEAT-08** | **Hồ sơ cá nhân (Profile & Guest)** | Xem và cập nhật thông tin cá nhân khách hàng/nhân viên | Thành viên 1 | [ ] Chờ xử lý |

---

## 📅 LỘ TRÌNH TRIỂN KHAI (SPRINT ROADMAP)

### Sprint 1: Nền tảng & Xác thực (Core, Auth & Room Catalog)
- Hoàn thiện Core: Theme, Network Client (Dio), Routes (`go_router`).
- Xây dựng tầng Auth (`features/auth`): Kết nối `PRN232.AuthAPI` để lấy JWT Token và lưu vào Secure Storage.
- Xây dựng Room & RoomType (`features/room`, `features/room_type`): Lấy danh sách phòng trống từ `PRN232.RoomAPI`.

### Sprint 2: Đặt phòng & Quản lý kỳ nghỉ (Booking & Stay)
- Xây dựng luồng Đặt phòng (`features/reservation`): Gọi `PRN232.ReservationAPI`.
- Xây dựng luồng Check-in & Hóa đơn (`features/stay`): Gọi `PRN232.StayAPI`.

### Sprint 3: Dịch vụ bổ sung, Tác vụ nhân viên & Hoàn thiện (Services & Tasks)
- Tích hợp Dịch vụ phòng (`features/hotel_service`): Gọi `PRN232.HotelServiceAPI` & `ServiceUsageAPI`.
- Màn hình dành cho nhân viên dọn phòng (`features/task`): Gọi `PRN232.TaskAPI`.
- Kiểm thử toàn diện (End-to-End Testing), tối ưu UX/UI và đóng gói APK.

