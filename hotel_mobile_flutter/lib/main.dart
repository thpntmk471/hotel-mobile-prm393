import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/dio_client.dart';
import 'core/storage/local_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/main_shell_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/hotel_service/data/datasources/hotel_service_remote_datasource.dart';
import 'features/hotel_service/data/repositories/hotel_service_repository_impl.dart';
import 'features/hotel_service/domain/repositories/hotel_service_repository.dart';
import 'features/hotel_service/presentation/providers/hotel_service_provider.dart';
import 'features/profile/data/datasources/profile_local_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/presentation/providers/profile_provider.dart';
import 'features/reservation/data/datasources/reservation_remote_datasource.dart';
import 'features/reservation/data/repositories/reservation_repository_impl.dart';
import 'features/reservation/domain/repositories/reservation_repository.dart';
import 'features/reservation/presentation/providers/reservation_provider.dart';
import 'features/room/data/datasources/room_remote_datasource.dart';
import 'features/room/data/repositories/room_repository_impl.dart';
import 'features/room/domain/repositories/room_repository.dart';
import 'features/room/presentation/providers/room_provider.dart';
import 'features/stay/data/datasources/stay_remote_datasource.dart';
import 'features/stay/data/repositories/stay_repository_impl.dart';
import 'features/stay/domain/repositories/stay_repository.dart';
import 'features/stay/presentation/providers/stay_provider.dart';
import 'features/task/data/datasources/task_remote_datasource.dart';
import 'features/task/data/repositories/task_repository_impl.dart';
import 'features/task/domain/repositories/task_repository.dart';
import 'features/task/presentation/providers/task_provider.dart';
import 'features/room_type/data/datasources/room_type_remote_datasource.dart';
import 'features/room_type/data/repositories/room_type_repository_impl.dart';
import 'features/room_type/domain/repositories/room_type_repository.dart';
import 'features/room_type/presentation/providers/room_type_provider.dart';
import 'features/guest/data/datasources/guest_remote_datasource.dart';
import 'features/guest/data/repositories/guest_repository_impl.dart';
import 'features/guest/domain/repositories/guest_repository.dart';
import 'features/guest/presentation/providers/guest_provider.dart';
import 'features/staff/data/datasources/staff_remote_datasource.dart';
import 'features/staff/data/repositories/staff_repository_impl.dart';
import 'features/staff/domain/repositories/staff_repository.dart';
import 'features/staff/presentation/providers/staff_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage();

  final storageService = LocalStorageService(
    secureStorage: secureStorage,
    prefs: prefs,
  );

  final dioClient = DioClient(storageService);
  final authRemoteDataSource = AuthRemoteDataSourceImpl(dioClient.dio);
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    storageService: storageService,
  );

  final roomRemoteDataSource = RoomRemoteDataSourceImpl(dioClient.dio);
  final roomRepository = RoomRepositoryImpl(roomRemoteDataSource);

  final guestRemoteDataSource = GuestRemoteDataSourceImpl(dioClient.dio);
  final guestRepository = GuestRepositoryImpl(guestRemoteDataSource);

  final staffRemoteDataSource = StaffRemoteDataSourceImpl(dioClient.dio);
  final staffRepository = StaffRepositoryImpl(staffRemoteDataSource);

  final reservationRemoteDataSource =
      ReservationRemoteDataSourceImpl(dioClient.dio);
  final reservationRepository = ReservationRepositoryImpl(
    reservationRemoteDataSource,
    roomRemoteDataSource: roomRemoteDataSource,
    guestRemoteDataSource: guestRemoteDataSource,
  );

  final stayRemoteDataSource = StayRemoteDataSourceImpl(dioClient.dio);
  final stayRepository = StayRepositoryImpl(
    stayRemoteDataSource,
    roomRemoteDataSource: roomRemoteDataSource,
    reservationRemoteDataSource: reservationRemoteDataSource,
    guestRemoteDataSource: guestRemoteDataSource,
  );

  final hotelServiceRemoteDataSource =
      HotelServiceRemoteDataSourceImpl(dioClient.dio);
  final hotelServiceRepository =
      HotelServiceRepositoryImpl(hotelServiceRemoteDataSource);

  final taskRemoteDataSource = TaskRemoteDataSourceImpl(dioClient.dio);
  final taskRepository = TaskRepositoryImpl(taskRemoteDataSource);

  final roomTypeRemoteDataSource = RoomTypeRemoteDataSourceImpl(dioClient.dio);
  final roomTypeRepository = RoomTypeRepositoryImpl(roomTypeRemoteDataSource);

  final profileLocalDataSource = ProfileLocalDataSourceImpl(storageService);
  final profileRepository = ProfileRepositoryImpl(profileLocalDataSource);

  runApp(
    MultiProvider(
      providers: [
        Provider<LocalStorageService>.value(value: storageService),
        Provider<DioClient>.value(value: dioClient),
        Provider<AuthRepository>.value(value: authRepository),
        Provider<RoomRepository>.value(value: roomRepository),
        Provider<ReservationRepository>.value(value: reservationRepository),
        Provider<StayRepository>.value(value: stayRepository),
        Provider<HotelServiceRepository>.value(value: hotelServiceRepository),
        Provider<TaskRepository>.value(value: taskRepository),
        Provider<RoomTypeRepository>.value(value: roomTypeRepository),
        Provider<GuestRepository>.value(value: guestRepository),
        Provider<StaffRepository>.value(value: staffRepository),
        Provider<ProfileRepository>.value(value: profileRepository),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => RoomProvider(roomRepository: roomRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => RoomTypeProvider(roomTypeRepository: roomTypeRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => GuestProvider(guestRepository: guestRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => StaffProvider(staffRepository: staffRepository),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ReservationProvider(reservationRepository: reservationRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => StayProvider(stayRepository: stayRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => HotelServiceProvider(
              serviceRepository: hotelServiceRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(taskRepository: taskRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(profileRepository: profileRepository),
        ),
      ],
      child: const HotelManagementApp(),
    ),
  );
}

class HotelManagementApp extends StatelessWidget {
  const HotelManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProv, _) {
        return MaterialApp(
          title: 'Hotel Management',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: profileProv.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: Consumer<AuthProvider>(
            builder: (context, auth, _) {
              if (auth.status == AuthStatus.initial) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (auth.isAuthenticated) {
                return const MainShellPage();
              }
              return const LoginPage();
            },
          ),
        );
      },
    );
  }
}

