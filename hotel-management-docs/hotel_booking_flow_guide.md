# Luồng Nghiệp Vụ Đặt Phòng Khách Sạn (Hotel Booking & Stay Flow)
## Từ Backend PRN232 Đến Giao Diện Flutter Mobile

Tài liệu này mô tả chi tiết quy trình xử lý dữ liệu của 2 luồng quan trọng nhất trong ứng dụng:
1. **Luồng Tìm kiếm & Đặt phòng (Guest Booking Flow)**
2. **Luồng Nhận phòng, Dịch vụ & Trả phòng (Check-in, Room Service & Check-out Flow)**

---

## 📊 1. SƠ ĐỒ LUỒNG ĐẶT PHÒNG (BOOKING FLOW DIAGRAM)

```mermaid
sequenceDiagram
    autonumber
    actor Guest as Khách Hàng (App)
    participant UI as Room & Booking Page
    participant VM as Riverpod Notifier
    participant UC as Reservation UseCase
    participant Repo as ReservationRepoImpl
    participant Dio as Dio Network Client
    participant RoomAPI as PRN232.RoomAPI (:5005)
    participant ResAPI as PRN232.ReservationAPI (:5006)
    participant DB as SQL Server (HOTEL_MANAGEMENT_DB)

    Guest->>UI: Chọn ngày Check-in/Check-out, loại phòng
    UI->>VM: loadAvailableRooms(filters)
    VM->>UC: execute()
    UC->>Repo: getAvailableRooms()
    Repo->>Dio: GET /api/Room/available?$filter=...
    Dio->>RoomAPI: HTTP GET Request
    RoomAPI->>DB: Query Rooms where Status == 'Available'
    DB-->>RoomAPI: Trả về record phòng
    RoomAPI-->>Dio: 200 OK [ { id: 101, roomNumber: "P.301", price: 500000 } ]
    Dio-->>Repo: Map JSON sang List<RoomModel>
    Repo-->>UC: Chuyển đổi .toEntity() thành List<Room>
    UC-->>VM: Trả về Entity sạch
    VM-->>UI: Cập nhật state RoomState.loaded()
    UI-->>Guest: Hiển thị danh sách phòng trống kèm giá

    Guest->>UI: Nhấn "Đặt phòng ngay"
    UI->>VM: createReservation(guestInfo, roomId, dates)
    VM->>Dio: POST /api/Reservation
    Dio->>ResAPI: Gửi payload ReservationDto
    ResAPI->>DB: INSERT INTO Reservations (Status: 'Confirmed')
    DB-->>ResAPI: Success
    ResAPI-->>Dio: 201 Created (ReservationId: 8899)
    Dio-->>VM: Cập nhật state BookingSuccess
    VM-->>UI: Hiển thị màn hình thành công & mã đặt phòng
```

---

## 📊 2. SƠ ĐỒ LUỒNG LƯU TRÚ & SỬ DỤNG DỊCH VỤ (STAY & SERVICE USAGE)

```mermaid
graph TD
    subgraph Quản Lý Đặt Chỗ & Nhận Phòng
        A[Khách Đến Khách Sạn] --> B[Nhân Viên Check-in qua Mobile App]
        B --> C[PRN232.StayAPI: Tạo bản ghi Stay]
        C --> D[Cập nhật trạng thái Room = 'Occupied']
    end

    subgraph Sử Dụng Dịch Vụ Khách Sạn
        E[Khách gọi dịch vụ: Giặt ủi / Ăn uống] --> F[Mobile App: Chọn dịch vụ từ HotelServiceAPI]
        F --> G[PRN232.ServiceUsageAPI: Tạo bản ghi ServiceUsage]
        G --> H[Tự động link vào Stay hiện tại]
    end

    subgraph Trả Phòng & Thanh Toán
        I[Khách Check-out] --> J[PRN232.StayAPI: Tính tổng Invoice = Tiền phòng + Dịch vụ]
        J --> K[Mobile App: Hiển thị hóa đơn chi tiết]
        K --> L[Xác nhận thanh toán Payment]
        L --> M[Cập nhật Room = 'Cleaning' và tạo Task cho Housekeeping]
    end

    D -.-> E
    H -.-> I
```

---

## 🔍 CHI TIẾT CÁC BƯỚC TRIỂN KHAI THEO LAYER TRÊN FLUTTER

### Bước 1: Gọi API tìm phòng (Presentation -> Network)
- **File UI:** `features/room/presentation/pages/room_list_page.dart`
- Người dùng chọn bộ lọc: Ngày nhận, Ngày trả, Loại phòng (`roomTypeId`).
- **Provider:** `room_notifier.dart` kích hoạt `fetchAvailableRooms`.
- **Dio Client:** Gửi query string qua `ApiConstants.roomUrl`.

### Bước 2: Nhận dữ liệu & Chuyển đổi Model sang Entity
- **File Model:** `features/room/data/models/room_model.dart`
  - Nhận JSON từ `PRN232.RoomAPI`.
  - Kiểm tra trường null an toàn, parse kiểu số sang double / int.
- **File Entity:** `features/room/domain/entities/room.dart`
  - Chuyển đổi qua phương thức:
    ```dart
    Room entity = roomModel.toEntity();
    ```

### Bước 3: Tạo đơn đặt chỗ (Reservation)
- **File Page:** `features/reservation/presentation/pages/booking_checkout_page.dart`
- Đóng gói dữ liệu đặt phòng:
  - `guestId`: Lấy từ phiên đăng nhập hiện tại (`AuthNotifier`).
  - `roomId`: Phòng đã chọn.
  - `checkInDate`, `checkOutDate`: Thời gian lưu trú.
- Gửi POST tới `ApiConstants.reservationUrl`.

### Bước 4: Gọi dịch vụ phòng (Hotel Services)
- Khách hàng có thể đặt thêm dịch vụ (Ăn uống, nước uống, spa) từ màn hình:
  `features/hotel_service/presentation/pages/service_catalog_page.dart`.
- App gửi request tới `PRN232.ServiceUsageAPI`, tự động gắn kèm mã `StayId` đang hoạt động của khách.

### Bước 5: Xem Hóa Đơn & Check-out (Stay & Invoices)
- Màn hình `features/stay/presentation/pages/stay_detail_page.dart` hiển thị:
  1. Chi phí tiền phòng theo số đêm.
  2. Chi tiết các dịch vụ đã sử dụng trong suốt kỳ nghỉ (`InvoiceLine`).
  3. Tổng tiền thanh toán và phương thức (Tiền mặt, VNPay/Chuyển khoản, Thẻ).

