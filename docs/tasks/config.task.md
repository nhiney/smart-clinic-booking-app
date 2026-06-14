
hãy đổi biến này privacyPolicyUrl (lib/core/constants/app_constants.dart) thành 1 file config được lưu trữ tại firestore sau cho thuận tiện về sau khi cần thay đổi chỉ cần thay đổi tại firestore mà không cần phải build lại app
ngoài ra tôi muốn sau này những biến config khác phải đặt tại file này, hãy cấu trúc file này thành 1 file js chuyên nghiệp 

tôi muốn file privacy_policy sẽ được chia làm nhiều version khi mà nhiều người dùng truy cập vào ứng dụng nhưng mà tại thời điểm đó tôi lỡ xoá file policy thì người dùng sẽ không thấy được, vì vậy cần lưu lại file policy version 1 tại firestore khi tôi xoá để update bản version 2 thì người dùng vẫn còn bản v1 để xem 

