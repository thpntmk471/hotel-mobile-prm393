class CountItemDto {
  final int code;
  final int count;

  const CountItemDto({required this.code, required this.count});

  factory CountItemDto.fromJson(Map<String, dynamic> json) {
    final rawCode = json['code'] ?? json['Code'] ?? 0;
    final rawCount = json['count'] ?? json['Count'] ?? 0;
    return CountItemDto(
      code: rawCode is int ? rawCode : int.tryParse(rawCode.toString()) ?? 0,
      count: rawCount is int ? rawCount : int.tryParse(rawCount.toString()) ?? 0,
    );
  }
}

class RoomReportModel {
  final int totalRooms;
  final int occupiedRoomsNow;
  final int blockedRoomsNow;
  final int availableRoomsNow;
  final int totalRoomNights;
  final int occupiedRoomNights;
  final double utilizationPercent;
  final List<CountItemDto> byOperationalStatus;
  final List<CountItemDto> byRoomType;
  final String fromDate;
  final String toDate;
  final String dataSource;
  final String? integrationNote;

  const RoomReportModel({
    required this.totalRooms,
    required this.occupiedRoomsNow,
    required this.blockedRoomsNow,
    required this.availableRoomsNow,
    required this.totalRoomNights,
    required this.occupiedRoomNights,
    required this.utilizationPercent,
    required this.byOperationalStatus,
    required this.byRoomType,
    required this.fromDate,
    required this.toDate,
    required this.dataSource,
    this.integrationNote,
  });

  factory RoomReportModel.fromJson(Map<String, dynamic> json) {
    List<CountItemDto> parseList(dynamic raw) {
      if (raw is List) {
        return raw.map((e) => CountItemDto.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    }

    final rawUtil = json['utilizationPercent'] ?? json['UtilizationPercent'] ?? 0;
    final util = rawUtil is num ? rawUtil.toDouble() : double.tryParse(rawUtil.toString()) ?? 0.0;

    return RoomReportModel(
      totalRooms: (json['totalRooms'] ?? json['TotalRooms'] ?? 0) as int,
      occupiedRoomsNow: (json['occupiedRoomsNow'] ?? json['OccupiedRoomsNow'] ?? 0) as int,
      blockedRoomsNow: (json['blockedRoomsNow'] ?? json['BlockedRoomsNow'] ?? 0) as int,
      availableRoomsNow: (json['availableRoomsNow'] ?? json['AvailableRoomsNow'] ?? 0) as int,
      totalRoomNights: (json['totalRoomNights'] ?? json['TotalRoomNights'] ?? 0) as int,
      occupiedRoomNights: (json['occupiedRoomNights'] ?? json['OccupiedRoomNights'] ?? 0) as int,
      utilizationPercent: util,
      byOperationalStatus: parseList(json['byOperationalStatus'] ?? json['ByOperationalStatus']),
      byRoomType: parseList(json['byRoomType'] ?? json['ByRoomType']),
      fromDate: (json['fromDate'] ?? json['FromDate'] ?? '').toString(),
      toDate: (json['toDate'] ?? json['ToDate'] ?? '').toString(),
      dataSource: (json['dataSource'] ?? json['DataSource'] ?? 'REAL_HTTP').toString(),
      integrationNote: (json['integrationNote'] ?? json['IntegrationNote'])?.toString(),
    );
  }
}

class ReservationReportModel {
  final int totalReservations;
  final int totalGuestsBooked;
  final List<CountItemDto> byStatus;
  final List<CountItemDto> byRoomType;
  final String fromDate;
  final String toDate;
  final String dataSource;

  const ReservationReportModel({
    required this.totalReservations,
    required this.totalGuestsBooked,
    required this.byStatus,
    required this.byRoomType,
    required this.fromDate,
    required this.toDate,
    required this.dataSource,
  });

  factory ReservationReportModel.fromJson(Map<String, dynamic> json) {
    List<CountItemDto> parseList(dynamic raw) {
      if (raw is List) {
        return raw.map((e) => CountItemDto.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    }

    return ReservationReportModel(
      totalReservations: (json['totalReservations'] ?? json['TotalReservations'] ?? 0) as int,
      totalGuestsBooked: (json['totalGuestsBooked'] ?? json['TotalGuestsBooked'] ?? 0) as int,
      byStatus: parseList(json['byStatus'] ?? json['ByStatus']),
      byRoomType: parseList(json['byRoomType'] ?? json['ByRoomType']),
      fromDate: (json['fromDate'] ?? json['FromDate'] ?? '').toString(),
      toDate: (json['toDate'] ?? json['ToDate'] ?? '').toString(),
      dataSource: (json['dataSource'] ?? json['DataSource'] ?? 'REAL_HTTP').toString(),
    );
  }
}

class RevenueDateItemDto {
  final String date;
  final double amount;
  final int paymentCount;

  const RevenueDateItemDto({
    required this.date,
    required this.amount,
    required this.paymentCount,
  });

  factory RevenueDateItemDto.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'] ?? json['Amount'] ?? 0;
    final amount = rawAmount is num ? rawAmount.toDouble() : double.tryParse(rawAmount.toString()) ?? 0.0;
    final rawCount = json['paymentCount'] ?? json['PaymentCount'] ?? 0;
    return RevenueDateItemDto(
      date: (json['date'] ?? json['Date'] ?? '').toString(),
      amount: amount,
      paymentCount: rawCount is int ? rawCount : int.tryParse(rawCount.toString()) ?? 0,
    );
  }
}

class RevenueMethodItemDto {
  final int method;
  final double amount;
  final int paymentCount;

  const RevenueMethodItemDto({
    required this.method,
    required this.amount,
    required this.paymentCount,
  });

  factory RevenueMethodItemDto.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'] ?? json['Amount'] ?? 0;
    final amount = rawAmount is num ? rawAmount.toDouble() : double.tryParse(rawAmount.toString()) ?? 0.0;
    final rawMethod = json['method'] ?? json['Method'] ?? 1;
    final rawCount = json['paymentCount'] ?? json['PaymentCount'] ?? 0;
    return RevenueMethodItemDto(
      method: rawMethod is int ? rawMethod : int.tryParse(rawMethod.toString()) ?? 1,
      amount: amount,
      paymentCount: rawCount is int ? rawCount : int.tryParse(rawCount.toString()) ?? 0,
    );
  }
}

class RevenueReportModel {
  final int paymentCount;
  final double totalReceived;
  final List<RevenueDateItemDto> byDate;
  final List<RevenueMethodItemDto> byMethod;
  final String fromDate;
  final String toDate;
  final String dataSource;

  const RevenueReportModel({
    required this.paymentCount,
    required this.totalReceived,
    required this.byDate,
    required this.byMethod,
    required this.fromDate,
    required this.toDate,
    required this.dataSource,
  });

  factory RevenueReportModel.fromJson(Map<String, dynamic> json) {
    final rawTotal = json['totalReceived'] ?? json['TotalReceived'] ?? 0;
    final total = rawTotal is num ? rawTotal.toDouble() : double.tryParse(rawTotal.toString()) ?? 0.0;

    List<RevenueDateItemDto> parseDates(dynamic raw) {
      if (raw is List) {
        return raw.map((e) => RevenueDateItemDto.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    }

    List<RevenueMethodItemDto> parseMethods(dynamic raw) {
      if (raw is List) {
        return raw.map((e) => RevenueMethodItemDto.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    }

    return RevenueReportModel(
      paymentCount: (json['paymentCount'] ?? json['PaymentCount'] ?? 0) as int,
      totalReceived: total,
      byDate: parseDates(json['byDate'] ?? json['ByDate']),
      byMethod: parseMethods(json['byMethod'] ?? json['ByMethod']),
      fromDate: (json['fromDate'] ?? json['FromDate'] ?? '').toString(),
      toDate: (json['toDate'] ?? json['ToDate'] ?? '').toString(),
      dataSource: (json['dataSource'] ?? json['DataSource'] ?? 'REAL_HTTP').toString(),
    );
  }
}

class TaskReportModel {
  final int totalTasks;
  final int completedTasks;
  final int unassignedTasks;
  final List<CountItemDto> byTaskType;
  final List<CountItemDto> byStatus;
  final List<CountItemDto> byAssignedAccount;
  final String fromDate;
  final String toDate;
  final String dataSource;

  const TaskReportModel({
    required this.totalTasks,
    required this.completedTasks,
    required this.unassignedTasks,
    required this.byTaskType,
    required this.byStatus,
    required this.byAssignedAccount,
    required this.fromDate,
    required this.toDate,
    required this.dataSource,
  });

  factory TaskReportModel.fromJson(Map<String, dynamic> json) {
    List<CountItemDto> parseList(dynamic raw) {
      if (raw is List) {
        return raw.map((e) => CountItemDto.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    }

    return TaskReportModel(
      totalTasks: (json['totalTasks'] ?? json['TotalTasks'] ?? 0) as int,
      completedTasks: (json['completedTasks'] ?? json['CompletedTasks'] ?? 0) as int,
      unassignedTasks: (json['unassignedTasks'] ?? json['UnassignedTasks'] ?? 0) as int,
      byTaskType: parseList(json['byTaskType'] ?? json['ByTaskType']),
      byStatus: parseList(json['byStatus'] ?? json['ByStatus']),
      byAssignedAccount: parseList(json['byAssignedAccount'] ?? json['ByAssignedAccount']),
      fromDate: (json['fromDate'] ?? json['FromDate'] ?? '').toString(),
      toDate: (json['toDate'] ?? json['ToDate'] ?? '').toString(),
      dataSource: (json['dataSource'] ?? json['DataSource'] ?? 'REAL_HTTP').toString(),
    );
  }
}

class ComprehensiveReportModel {
  final RoomReportModel rooms;
  final ReservationReportModel reservations;
  final RevenueReportModel revenue;
  final TaskReportModel tasks;
  final DateTime generatedAt;

  const ComprehensiveReportModel({
    required this.rooms,
    required this.reservations,
    required this.revenue,
    required this.tasks,
    required this.generatedAt,
  });
}

