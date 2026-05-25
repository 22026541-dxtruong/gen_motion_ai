# 🌐 Gen Motion AI (Web Frontend)

Gen Motion AI là nền tảng Web cho phép người dùng tạo, quản lý và khám phá những nội dung video/hình ảnh được tạo bởi Trí tuệ nhân tạo (AI). Nền tảng được xây dựng dựa trên những công nghệ web hiện đại nhất nhằm mang lại tốc độ vượt trội và trải nghiệm thị giác tuyệt đẹp.

## 🚀 Tính năng nổi bật

- **Giao diện Web mượt mà (Modern UI)**: Giao diện web được thiết kế sang trọng, hỗ trợ các hiệu ứng hình ảnh (Glassmorphism, Gradients) và tối ưu hóa 100% cho mọi thiết bị (Responsive Design).
- **Hệ thống tạo Video bằng AI**: Cung cấp giao diện để nhập prompt, tinh chỉnh các tham số, và gửi yêu cầu tạo video lên Cloud/Modal servers.
- **Trình phát Video tương tác**: Trải nghiệm xem video liền mạch với các tính năng Like, Comment, Follow được cập nhật theo thời gian thực (Real-time).
- **Trang Cá nhân & Thanh toán**: Quản lý các dự án AI, theo dõi số dư Credits, xem thống kê tương tác, tích hợp nạp tiền nhanh chóng.
- **Tối ưu SEO**: Render SSR mạnh mẽ thông qua Next.js App Router, giúp nội dung dễ dàng được tìm thấy trên các công cụ tìm kiếm.

## 🛠 Tech Stack (Công nghệ sử dụng)

- **Framework**: [Next.js 16](https://nextjs.org/) (App Router).
- **UI Library**: [React 19](https://react.dev/).
- **Styling**: [TailwindCSS 4](https://tailwindcss.com/) cho việc viết CSS nhanh và mạnh mẽ.
- **Data Fetching**: [SWR](https://swr.vercel.app/) (Stale-While-Revalidate) xử lý fetch và caching API.
- **Icons**: [Lucide React](https://lucide.dev/).
- **Ngôn ngữ**: [TypeScript](https://www.typescriptlang.org/) đảm bảo độ ổn định của hệ thống.

## ⚙️ Cài đặt và Khởi chạy

### 1. Yêu cầu môi trường
- [Node.js](https://nodejs.org/en/) (phiên bản 22.x trở lên).
- Trình quản lý gói: `npm`, `yarn`, `pnpm`, hoặc `bun`.

### 2. Tải các gói phụ thuộc (Dependencies)
Mở terminal tại thư mục gốc của dự án và chạy:
```bash
npm install
# hoặc
yarn install
```

### 3. Khởi chạy máy chủ phát triển (Development Server)
```bash
npm run dev
# hoặc
yarn dev
```
Mở trình duyệt và truy cập: [http://localhost:5173](http://localhost:5173) để xem dự án. 
Mọi thay đổi trên mã nguồn sẽ được hệ thống cập nhật tự động nhờ tính năng Fast Refresh.

### 4. Build phiên bản Product (Production Build)
Khi đã sẵn sàng đưa web lên máy chủ, chạy lệnh sau để build bản tối ưu hóa:
```bash
npm run build
npm run start
```

## 🏗 Cấu trúc mã nguồn cơ bản

```text
gen_motion_ai/
├── app/                  # Chứa toàn bộ các trang web (App Router Next.js)
│   ├── post/[id]/        # Trang chi tiết bài đăng video
│   ├── page.tsx          # Trang chủ
│   └── layout.tsx        # Cấu trúc chung (Header, Footer, Provider)
├── components/           # (Tùy chọn) Chứa các UI components dùng chung (Buttons, Modals, Cards...)
├── public/               # Chứa các tài nguyên tĩnh (Fonts, Images, Icons)
├── package.json          # Quản lý thư viện và scripts hệ thống
└── tailwind.config.ts    # Cấu hình giao diện và màu sắc cho dự án
```
