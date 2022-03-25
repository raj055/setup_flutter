import 'package:get/get.dart';

import '../../../../mlm/payout/vendor_payout.dart';
import '../../../../mlm/support/ticketCreate.dart';
import '../../../../mlm/vendor/vendor_invoice.dart';
import '../../../../mlm/vendor/vendor_wallet_transaction.dart';
import '../../../../shopping/best-seller/best_saller.dart';
import '../../../../widget/pdf_viewer.dart';
import '../../../mlm/support/supportChat.dart';
import '../../../mlm/support/supportList.dart';
import '../../../mlm/vendor/offline_order.dart';
import '../../../mlm/vendor/qr_code_details.dart';
import '../../../mlm/vendor/vendor_map.dart';
import '../../../shopping/recharge/dth_recharge.dart';
import '../../../shopping/recharge/electricity_bill.dart';
import '../../../shopping/recharge/gas_cylinder.dart';
import '../../../shopping/recharge/mobile_recharge.dart';
import '../../../shopping/recharge/rechargeSummary.dart';
import '../../../shopping/review/review-add.dart';
import '../../mlm/account/banking-partner.dart';
import '../../mlm/account/transactionChangePassword.dart';
import '../../mlm/auth_mlm/change-password.dart';
import '../../mlm/pin/pin_request.dart';
import '../../mlm/pin/pin_request_list.dart';
import '../../mlm/withdrawal/withdrawal_list.dart';
import '../../mlm/withdrawal/withdrawal_request.dart';
import '../../shopping/cart-payment/payments.dart';
import '../../shopping/cart-payment/thanks.dart';
import '../../shopping/languageVideo.dart';
import '../../shopping/order/my_order_detail.dart';
import '../../shopping/review/review-list.dart';
import '../../shopping/trending/trending_list.dart';
import '../../widget/photo_zoom.dart';
import '../mlm/TopUp/TopUp-View.dart';
import '../mlm/TopUp/TopUp.dart';
import '../mlm/account/KYC-details.dart';
import '../mlm/account/ProfileScreen.dart';
import '../mlm/auth_mlm/foregtPassword.dart';
import '../mlm/auth_mlm/login_mlm.dart';
import '../mlm/auth_mlm/register.dart';
import '../mlm/dashboard/dashboard.dart';
import '../mlm/genyology/mlm_genealogy.dart';
import '../mlm/income/income.dart';
import '../mlm/payout/payout.dart';
import '../mlm/pin/pin_list.dart';
import '../mlm/reports/reports.dart';
import '../mlm/wallet/wallet.dart';
import '../shopping/account/my_account.dart';
import '../shopping/app-services/appUpdateScreen.dart';
import '../shopping/app-services/apppMaintance.dart';
import '../shopping/app-services/no_internet.dart';
import '../shopping/cart-payment/cart.dart';
import '../shopping/category/category.dart';
import '../shopping/category/sub_category.dart';
import '../shopping/home_ecommerce.dart';
import '../shopping/notification/notification.dart';
import '../shopping/order/my_orders.dart';
import '../shopping/product/product_detail.dart';
import '../shopping/product/products.dart';
import '../shopping/product/search_page.dart';
import '../shopping/wishlist/wishlist.dart';
import '../spalsh_logo.dart';
import '../widget/something_went_wrong.dart';

class CustomRouter {
  static List<GetPage> pages = [
    GetPage(name: '/', page: () => SplashLogo()),
    GetPage(name: '/no-internet', page: () => NoInternet()),
    GetPage(name: '/app-maintenance', page: () => AppMaintenance()),
    GetPage(name: '/app-update', page: () => AppUpdate()),

    // MLM
    GetPage(name: '/something-went-wrong', page: () => SomethingWentWrong()),
    GetPage(name: '/login-mlm', page: () => LoginMLM()),
    GetPage(name: '/register-mlm', page: () => Register()),
    GetPage(name: '/forget-password-mlm', page: () => ForgotPassword()),
    GetPage(name: '/change-password', page: () => ChangePassword()),
    GetPage(name: '/profile-mlm', page: () => ProfileScreen()),
    GetPage(name: '/top-up-mlm', page: () => TopUp()),
    GetPage(name: '/top-up-view-mlm', page: () => TopUpView()),
    GetPage(name: '/pin-list-mlm', page: () => PinList()),
    GetPage(name: '/kyc', page: () => KycDetails()),
    GetPage(name: '/dashboard', page: () => Dashboard()),
    GetPage(name: '/reports', page: () => Reports()),
    GetPage(name: '/withdrawal-request-list', page: () => WithdrawalList()),
    GetPage(name: '/withdrawal-request', page: () => WithdrawalCreate()),
    GetPage(name: '/genealogy-mlm', page: () => MLMGenealogy()),
    GetPage(name: '/income-mlm', page: () => Incomes()),
    GetPage(name: '/banking-partner', page: () => BankingPartner()),
    GetPage(name: '/payout', page: () => Payout()),
    GetPage(name: '/wallet', page: () => Wallet()),
    GetPage(name: '/pin-request', page: () => PinRequest()),
    GetPage(name: '/pin-request-list', page: () => PinRequestList()),
    GetPage(name: '/photo-zoom', page: () => PhotoZoom()),
    GetPage(name: '/transaction-change-password', page: () => TransactionChangePassword()),
    GetPage(name: '/vendor-payout', page: () => VendorPayout()),
    GetPage(name: '/pdf-viewer', page: () => PDFViewer()),

    //Shopping
    GetPage(name: '/language-video', page: () => LanguageVideo()),
    GetPage(name: '/ecommerce', page: () => HomeECommerce()),
    GetPage(name: '/category', page: () => Category()),
    GetPage(name: '/sub-category', page: () => SubCategory()),
    GetPage(name: '/product-list', page: () => ProductListing()),
    GetPage(name: '/product-detail', page: () => ProductDetail()),
    GetPage(name: '/search-page', page: () => SearchPage()),
    GetPage(name: '/wishlist', page: () => WishList()),
    GetPage(name: '/orders', page: () => MyOrders()),
    GetPage(name: '/support', page: () => SupportList()),
    GetPage(name: '/support-chat', page: () => SupportChat()),
    GetPage(name: '/ticket-create', page: () => TicketCreate()),
    GetPage(name: '/my-order-detail', page: () => MyOrderDetail()),
    GetPage(name: '/account', page: () => MyAccount()),
    GetPage(name: '/cart', page: () => Cart()),
    GetPage(name: '/trending-list', page: () => TrendingList()),
    GetPage(name: '/best-seller-page', page: () => BestSellerPage()),
    GetPage(name: '/notification', page: () => Notification()),
    GetPage(name: '/review-list', page: () => ReviewList()),
    GetPage(name: '/review-add', page: () => ReviewAdd()),
    GetPage(name: '/payments', page: () => Payments()),
    GetPage(name: '/shopping-thanks', page: () => Thanks()),

    // Vendor
    GetPage(name: '/qr-view', page: () => QRView()),
    GetPage(name: '/off-line-orders', page: () => OffLineOrders()),
    GetPage(name: '/near-me-store', page: () => NearMeStore()),
    GetPage(name: '/vendor-invoice', page: () => VendorInvoice()),
    GetPage(name: '/vendor-wallet-transaction', page: () => VendorWalletTransaction()),

    // Recharge
    GetPage(name: '/dth-recharge', page: () => DthRecharge()),
    GetPage(name: '/electricity-bill', page: () => ElectricityBill()),
    GetPage(name: '/gas-cylinder', page: () => GasCylinder()),
    GetPage(name: '/mobile-recharge', page: () => MobileRecharge()),
    GetPage(name: '/recharge-summary', page: () => RechargeSummary()),
  ];
}
