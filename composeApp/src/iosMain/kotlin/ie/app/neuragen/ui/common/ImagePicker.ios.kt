package ie.app.neuragen.ui.common

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import kotlinx.cinterop.ExperimentalForeignApi
import platform.Foundation.NSFileManager
import platform.Foundation.NSTemporaryDirectory
import platform.Foundation.NSURL
import platform.Foundation.NSUUID
import platform.PhotosUI.PHPickerConfiguration
import platform.PhotosUI.PHPickerFilter
import platform.PhotosUI.PHPickerResult
import platform.PhotosUI.PHPickerViewController
import platform.PhotosUI.PHPickerViewControllerDelegateProtocol
import platform.UIKit.UIApplication
import platform.darwin.NSObject
import platform.darwin.dispatch_async
import platform.darwin.dispatch_get_main_queue

@OptIn(ExperimentalForeignApi::class)
@Composable
actual fun rememberImagePickerLauncher(onResult: (String?) -> Unit): () -> Unit {
    val delegate = remember {
        object : NSObject(), PHPickerViewControllerDelegateProtocol {
            override fun picker(picker: PHPickerViewController, didFinishPicking: List<*>) {
                // Đóng màn hình picker ngay lập tức
                picker.dismissViewControllerAnimated(true, null)

                val result = didFinishPicking.firstOrNull() as? PHPickerResult
                if (result == null) {
                    onResult(null) // Người dùng bấm Cancel
                    return
                }

                val itemProvider = result.itemProvider
                // Lấy định dạng file (ví dụ: public.image, public.movie)
                val typeIdentifier = itemProvider.registeredTypeIdentifiers.firstOrNull() as? String

                if (typeIdentifier != null && itemProvider.hasItemConformingToTypeIdentifier(typeIdentifier)) {

                    // Yêu cầu hệ thống load file vật lý
                    itemProvider.loadFileRepresentationForTypeIdentifier(typeIdentifier) { url, error ->
                        if (url != null) {
                            // 1. Tạo đường dẫn đích trong thư mục tạm (Temp Directory) của ứng dụng
                            val tempDir = NSTemporaryDirectory()
                            val originalFileName = url.lastPathComponent ?: "media_file"
                            // Dùng UUID để tránh trùng tên file nếu user chọn cùng 1 ảnh nhiều lần
                            val uniqueFileName = "${NSUUID().UUIDString}_$originalFileName"
                            val destUrl = NSURL.fileURLWithPath("$tempDir$uniqueFileName")

                            // 2. Copy file từ hệ thống vào thư mục tạm (phải làm NGAY trong block này)
                            val fileManager = NSFileManager.defaultManager
                            fileManager.copyItemAtURL(url, destUrl, null)

                            // 3. Đẩy kết quả về Main Thread để Compose cập nhật UI an toàn
                            dispatch_async(dispatch_get_main_queue()) {
                                // Trả về đường dẫn vật lý (path) thay vì absoluteString
                                onResult(destUrl.path)
                            }
                        } else {
                            // Xử lý lỗi load file
                            dispatch_async(dispatch_get_main_queue()) {
                                println("Lỗi load file iOS: ${error?.localizedDescription}")
                                onResult(null)
                            }
                        }
                    }
                } else {
                    onResult(null)
                }
            }
        }
    }

    return {
        // Cấu hình chỉ cho phép chọn Ảnh và Video
        val config = PHPickerConfiguration().apply {
            filter = PHPickerFilter.anyFilterMatchingSubfilters(
                listOf(PHPickerFilter.imagesFilter(), PHPickerFilter.videosFilter())
            )
            selectionLimit = 1
        }

        // Khởi tạo ViewController
        val picker = PHPickerViewController(configuration = config)
        picker.delegate = delegate

        // Tìm Root ViewController hiện tại của iOS để show Picker lên
        val rootViewController = UIApplication.sharedApplication.keyWindow?.rootViewController
        rootViewController?.presentViewController(picker, animated = true, completion = null)
    }
}