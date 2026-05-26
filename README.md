# 🚀 NeuraGen (Mobile Application)

NeuraGen là ứng dụng di động đa nền tảng (Cross-platform Mobile App) được xây dựng trên kiến trúc **Kotlin Multiplatform (KMP)** và giao diện người dùng **Compose Multiplatform**. Ứng dụng tập trung vào trải nghiệm cuộn video ngắn cao cấp, chia sẻ nội dung AI, và cung cấp hiệu năng mượt mà nhất trên cả Android lẫn iOS.

## 🌟 Tính năng nổi bật

- **Giao diện đẳng cấp (Premium UI)**: Lấy cảm hứng từ các thiết kế hiện đại, mượt mà với Micro-animations, Blur effects và Glassmorphism. Hỗ trợ đầy đủ **Dark Mode** & **Light Mode** tự động theo hệ thống.
- **Cuộn Video Short (Feed)**: Trình phát video natively được tối ưu hóa cho tốc độ tải và cuộn vô tận. (Sử dụng ExoPlayer trên Android và AVPlayer trên iOS).
- **Khám phá (Explore/Search)**: Tìm kiếm nội dung, trending và AI generated videos nhanh chóng.
- **Hồ sơ Cá nhân (Profile)**: Quản lý video của bạn, lượt theo dõi, thông tin cá nhân và cài đặt thanh toán/Credits.
- **Đăng nhập liền mạch**: Hỗ trợ Google Sign-In, Apple Sign-In (trên iOS) và Email/Mật khẩu truyền thống.
- **Offline First**: Đồng bộ hoá nền và lưu trữ bộ nhớ đệm với Room Database (SQLite) & DataStore.

## 🛠 Công nghệ cốt lõi

Dự án này tuân thủ chặt chẽ kiến trúc chia sẻ tối đa mã nguồn (Shared Code) qua `commonMain`:

- **UI Framework**: [Compose Multiplatform](https://www.jetbrains.com/lp/compose-multiplatform/) (Share 100% UI cho Android và iOS).
- **Mạng (Networking)**: [Ktor Client](https://ktor.io/) để kết nối API.
- **Dependency Injection**: [Koin](https://insert-koin.io/) hỗ trợ KMP và Compose.
- **Lưu trữ nội bộ (Local Storage)**: [Room Database](https://developer.android.com/training/data-storage/room) & [DataStore](https://developer.android.com/topic/libraries/architecture/datastore) (Phiên bản hỗ trợ KMP).
- **Xử lý Ảnh/Video**: [Coil3](https://coil-kt.github.io/coil/) cho Image Caching, API Native (`AVFoundation` và `Media3`) cho Video.
- **Điều hướng (Navigation)**: Jetbrains Navigation3 & Lifecycle ViewModels.

## 📦 Hướng dẫn cài đặt và chạy ứng dụng

### Yêu cầu hệ thống
- **Android Studio** (Koala hoặc mới nhất) / **IntelliJ IDEA**.
- **Xcode** 15+ (Để build và chạy phiên bản iOS).
- JDK 17+.

### Chạy trên Android
Sử dụng công cụ Run Configuration của Android Studio hoặc chạy lệnh qua Terminal:

- **macOS/Linux**:
  ```bash
  ./gradlew :composeApp:assembleDebug
  ```
- **Windows**:
  ```bash
  .\gradlew.bat :composeApp:assembleDebug
  ```

### Chạy trên iOS
1. Mở thư mục `iosApp` bằng **Xcode** (`iosApp/iosApp.xcodeproj`).
2. Dự án yêu cầu gói thư viện Google Sign-In. Hãy thêm nó thủ công vào Xcode theo các bước sau (nếu bị báo lỗi No such module 'GoogleSignIn'):
   - Chọn menu **File > Add Package Dependencies...**
   - Dán URL: `https://github.com/google/GoogleSignIn-iOS` vào ô tìm kiếm.
   - Nhấn **Add Package** và đảm bảo chọn target là `iosApp`.
3. Chọn thiết bị giả lập (Simulator) hoặc iPhone thực tế và nhấn nút **Run** (Play) trên Xcode.

## 📂 Cấu trúc thư mục dự án

```text
NeuraGen/
├── composeApp/              # Chứa toàn bộ logic và UI của ứng dụng
│   ├── src/commonMain/      # Code dùng chung (UI Compose, ViewModel, Ktor, Room)
│   ├── src/androidMain/     # Code đặc thù Android (ExoPlayer, GoogleSignIn CredentialManager)
│   └── src/iosMain/         # Code đặc thù iOS (AVPlayer, GoogleSignIn Interface)
├── iosApp/                  # Project Xcode gốc để build ra ứng dụng iOS (.ipa)
└── gradle/                  # Cấu hình Gradle chung
```