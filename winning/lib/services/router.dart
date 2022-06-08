import 'package:get/get.dart' hide Response;

import '../screens/CEP_Prime/cep_prime_category_search.dart';
import '../screens/CEP_Prime/cep_prime_home.dart';
import '../screens/CoreStep/core_steps.dart';
import '../screens/CoreStep/member_core_step_details.dart';
import '../screens/CoreStep/membes_core_step_list.dart';
import '../screens/Inspiration_club/inspiration_category_search.dart';
import '../screens/Inspiration_club/inspiration_club_list.dart';
import '../screens/InvitaionScript/invitation_category.dart';
import '../screens/InvitaionScript/invitation_script.dart';
import '../screens/Learning/audio-tutorial.dart';
import '../screens/Learning/ebook.dart';
import '../screens/Learning/ebookDetails.dart';
import '../screens/Learning/learning_audio_content_search.dart';
import '../screens/Learning/learning_audio_search.dart';
import '../screens/Learning/learning_ebook_content_search.dart';
import '../screens/Learning/learning_ebook_search.dart';
import '../screens/Learning/learning_video_content_search.dart';
import '../screens/Learning/learning_video_search.dart';
import '../screens/Learning/purchased_courses.dart';
import '../screens/Learning/video-tutorial.dart';
import '../screens/Learning/video_details.dart';
import '../screens/Learning/video_list.dart';
import '../screens/PromoCode/promo_code.dart';
import '../screens/PromoCode/promocode_thanks.dart';
import '../screens/PromoCode/purchase_promocode.dart';
import '../screens/Upgrade/upgrade_package.dart';
import '../screens/about/about_cep.dart';
import '../screens/about/about_us.dart';
import '../screens/about/about_vestige.dart';
import '../screens/about/contact_us.dart';
import '../screens/activity.dart';
import '../screens/analytics.dart';
import '../screens/app-language.dart';
import '../screens/appUpdateScreen.dart';
import '../screens/apppMaintance.dart';
import '../screens/auth/login.dart';
import '../screens/auth/otp.dart';
import '../screens/badge/my_badge.dart';
import '../screens/badge/request_for_badge.dart';
import '../screens/badge/user_history.dart';
import '../screens/badge/view_request.dart';
import '../screens/broadcast/broadcast_view.dart';
import '../screens/broadcast/broadcasts.dart';
import '../screens/broadcast/category_my_broadcast.dart';
import '../screens/broadcast/create_broadcast.dart';
import '../screens/broadcast/edit_broadcast.dart';
import '../screens/broadcast/edit_members_broadcast.dart';
import '../screens/broadcast/my_broadcast.dart';
import '../screens/broadcast/new_broadcast.dart';
import '../screens/broadcast/team_broadcast.dart';
import '../screens/cpe/cep_category_search.dart';
import '../screens/cpe/eLibrary_list.dart';
import '../screens/documents/document_audio_search.dart';
import '../screens/documents/document_ebook_search.dart';
import '../screens/documents/document_ebook_view.dart';
import '../screens/documents/document_video_play.dart';
import '../screens/documents/document_video_search.dart';
import '../screens/documents/document_video_tool.dart';
import '../screens/dream/EditDream.dart';
import '../screens/dream/dream_create.dart';
import '../screens/dream/dream_list.dart';
import '../screens/dream/dream_pick.dart';
import '../screens/expiredUser/promoCodeList.dart';
import '../screens/expiredUser/renewPackage.dart';
import '../screens/faq_list.dart';
import '../screens/feedback.dart';
import '../screens/gallery/cover_photos.dart';
import '../screens/gallery/list_photos.dart';
import '../screens/gallery/photo_zoom.dart';
import '../screens/genealogy.dart';
import '../screens/guest/addGuest.dart';
import '../screens/guest/guest_list.dart';
import '../screens/guestGift/giftSharing/gift_sharing.dart';
import '../screens/guestGift/gift_member_list.dart';
import '../screens/guestGift/guest_gift.dart';
import '../screens/guestGift/purchase_gift.dart';
import '../screens/guestGift/thanks_page.dart';
import '../screens/guest_dashboard.dart';
import '../screens/home.dart';
import '../screens/master_search.dart';
import '../screens/meeting/Webinar_create.dart';
import '../screens/meeting/meeting_details.dart';
import '../screens/meeting/meeting_list.dart';
import '../screens/meeting/seminar_create.dart';
import '../screens/my_vestige/my_vestige_list.dart';
import '../screens/my_vestige/myvistige_category_search.dart';
import '../screens/news.dart';
import '../screens/no_internet.dart';
import '../screens/notes/add_note.dart';
import '../screens/notes/note_search.dart';
import '../screens/notes/note_view.dart';
import '../screens/notification.dart';
import '../screens/profile/update_profile.dart';
import '../screens/purchaseCart/cart_page.dart';
import '../screens/purchaseCart/thanks_page.dart';
import '../screens/request/raise-request.dart';
import '../screens/request/request_warning_popup.dart';
import '../screens/spalsh_logo.dart';
import '../screens/splash.dart';
import '../screens/team/MyTeam/badge_acheivers.dart';
import '../screens/team/MyTeam/badge_acheivers_list.dart';
import '../screens/team/MyTeam/create_team.dart';
import '../screens/team/MyTeam/edit_team.dart';
import '../screens/team/MyTeam/my_team.dart';
import '../screens/team/MyTeam/team_details.dart';
import '../screens/team/associate_name_analytics.dart';
import '../screens/team/detailsAnalytics.dart';
import '../screens/team/detailsTeamActivity.dart';
import '../screens/team/detailsTeamDream.dart';
import '../screens/team/pendingRequest.dart';
import '../screens/team/teamActivity.dart';
import '../screens/team/teamAnalytics.dart';
import '../screens/team/teamDream.dart';
import '../screens/team/team_requestList.dart';
import '../screens/test.dart';
import '../screens/testimonial_add.dart';
import '../screens/tetsimonials.dart';
import '../screens/training/video_training.dart';
import '../test1.dart';
import '../widget/something_went_wrong.dart';

class AppRouter {
  static List<GetPage> pages = [
    GetPage(name: '/', page: () => SplashLogo()),
    GetPage(name: 'splash', page: () => Splash()),
    GetPage(name: 'login', page: () => Login()),
    GetPage(name: 'otp', page: () => Otp()),
    GetPage(name: 'home', page: () => Home(), binding: HomeBinding()),
    GetPage(name: 'no-internet', page: () => NoInternet()),
    GetPage(name: 'app-maintenance', page: () => AppMaintenance()),
    GetPage(name: 'app-update', page: () => AppUpdate()),
    GetPage(name: 'notification', page: () => Notification()),
    GetPage(name: 'dream-list', page: () => DreamList()),
    GetPage(name: 'dream-add', page: () => DreamCreate()),
    GetPage(name: 'dream-pick', page: () => DreamPick()),
    GetPage(name: 'dream-edit', page: () => EditDream()),
    GetPage(name: 'guest-list', page: () => GuestList()),
    GetPage(name: 'guest-add', page: () => AddGuest()),
    GetPage(name: 'profile-update', page: () => UpdateProfile()),
    GetPage(
        name: 'video-tutorial',
        page: () => VideoScreen(),
        binding: HomeBinding()),
    GetPage(name: 'learning-video-list', page: () => LearningVideoList()),
    GetPage(
        name: 'audio-tutorial',
        page: () => AudioScreen(),
        binding: HomeBinding()),
    GetPage(name: 'learning-audio-list', page: () => LearningVideoList()),
    GetPage(
        name: 'ebook-tutorial',
        page: () => EBookScreen(),
        binding: HomeBinding()),
    GetPage(name: 'learning-ebook-list', page: () => EBookDetails()),
    GetPage(name: 'broadcast-my', page: () => MyBroadcast()),
    GetPage(name: 'category-my-broadcast', page: () => CategoryMyBroadcast()),
    GetPage(name: 'broadcast-team', page: () => TeamBroadcast()),
    GetPage(name: 'analytics', page: () => Analytics()),
    GetPage(name: 'activity', page: () => Activity()),
    GetPage(name: 'my-team', page: () => MyTeam()),
    GetPage(name: 'create-team', page: () => CreteTeam()),
    GetPage(name: 'team-details', page: () => TeamDetails()),
    GetPage(name: 'edit-team', page: () => EditTeam()),
    GetPage(name: 'team_request_list', page: () => TeamRequestList()),
    GetPage(name: 'team-activity', page: () => TeamActivity()),
    GetPage(name: 'team-analytics', page: () => TeamAnalytics()),
    GetPage(name: 'team-dream', page: () => TeamDream()),
    GetPage(name: 'gallery-view', page: () => GalleryView()),
    GetPage(name: 'news', page: () => NewsHistory()),
    GetPage(name: 'note', page: () => Notes()),
    GetPage(name: 'addNote', page: () => AddNote()),
    GetPage(name: 'testimonials', page: () => Testimonials()),
    GetPage(name: 'about-us', page: () => AboutUs()),
    GetPage(name: 'about-vestige', page: () => AboutVestige()),
    GetPage(name: 'about-cep', page: () => AboutCep()),
    GetPage(name: 'contact-us', page: () => ContactUs()),
    GetPage(name: 'invitation-script', page: () => InvitationScript()),
    GetPage(name: 'invitation-category', page: () => InvitationCategory()),
    GetPage(name: 'photo-zoom', page: () => PhotoZoom()),
    GetPage(name: 'feedback', page: () => FeedBack()),
    GetPage(name: 'pending_request', page: () => PendingRequest()),
    GetPage(name: 'learning/video_details', page: () => VideoDetails()),
    GetPage(name: 'training/video_training', page: () => VideoTraining()),
    GetPage(
        name: 'associate_name_analytics', page: () => AssociateNameAnalytics()),
    GetPage(name: 'elibrary_list', page: () => ELibraryList()),
    GetPage(name: 'my_vestige_list', page: () => MyVestigeList()),
    GetPage(name: 'inspiration_club_List', page: () => InspirationClubList()),
    GetPage(name: 'testimonial-add', page: () => TestimonialAdd()),
    GetPage(name: 'note-search', page: () => NoteSearch()),
    GetPage(name: 'meeting_list', page: () => MeetingList()),
    GetPage(name: 'meeting_details', page: () => MeetingDetails()),
    GetPage(name: 'webinar_create', page: () => WebinarCreate()),
    GetPage(name: 'seminar_create', page: () => SeminarCreate()),
    GetPage(name: 'master_search', page: () => MasterSearch()),
    GetPage(name: 'learning-video-search', page: () => LearningVideoSearch()),
    GetPage(name: 'learning-audio-search', page: () => LearningAudioSearch()),
    GetPage(name: 'learning-ebook-search', page: () => LearningEBookSearch()),
    GetPage(
        name: 'learning-ebook-content-search/:learningId',
        page: () => LearningEBookContentSearch()),
    GetPage(name: 'guest-dashboard', page: () => GuestDashboard()),
    GetPage(
        name: 'learning-audio-content-search/:learningaudioId',
        page: () => LearningAudioContentSearch()),
    GetPage(
        name: 'learning-video-content-search/:learningvideoId',
        page: () => LearningVideoContentSearch()),
    GetPage(name: 'promo_code', page: () => PromoCode()),
    GetPage(name: 'purchase_promocode', page: () => PurchasePromoCode()),
    GetPage(name: 'upgrade_package', page: () => UpgradePackage()),
    GetPage(name: 'promocode_thanks', page: () => PromoCodeThanks()),
    GetPage(name: 'faq-question', page: () => FaqList()),
    GetPage(name: 'request-badge', page: () => RequestForBadge()),
    GetPage(name: 'user-history', page: () => UserHistory()),
    GetPage(name: 'view-request', page: () => ViewRequest()),
    GetPage(name: 'my-badge', page: () => MyBadge()),
    GetPage(name: 'badge-achiever', page: () => BadgeAchiever()),
    GetPage(name: 'badge-acheiver-list', page: () => BadgeAchieverList()),
    GetPage(name: 'document_ebook_view', page: () => DocumentEBookView()),
    GetPage(name: 'document_video_play', page: () => DocumentVideoPlay()),
    GetPage(name: 'document_video_tool', page: () => DocumentVideoTool()),
    GetPage(name: 'cart', page: () => CartPage()),
    GetPage(name: 'thanks', page: () => ThanksPage()),
    GetPage(name: 'app-language', page: () => AppLanguage()),
    GetPage(name: 'purchased-courses', page: () => PurchasedCourses()),
    GetPage(name: 'raise-request', page: () => RaiseRequest()),
    GetPage(name: 'teamDream-details', page: () => DetailsTeamDream()),
    GetPage(name: 'analytics-details', page: () => DetailsAnalytics()),
    GetPage(name: 'teamActivity-details', page: () => DetailsTeamActivity()),
    GetPage(name: 'gallery-photos', page: () => GalleryMorePhotos()),
    GetPage(name: 'broadcasting', page: () => Broadcasts()),
    GetPage(name: 'broadcast-view', page: () => BroadcastView()),
    GetPage(name: 'broadcast-new', page: () => NewBroadcast()),
    GetPage(name: 'broadcast-create', page: () => CreateBroadcast()),
    GetPage(name: 'genealogy', page: () => Genealogy()),
    GetPage(name: 'edit-broadcast', page: () => EditBroadcast()),
    GetPage(name: 'edit-broadcast-members', page: () => EditBroadcastMembers()),
    GetPage(
        name: 'my-vestige-category-search',
        page: () => MyVestigeCategorySearch()),
    GetPage(
        name: 'inspiration-category-search',
        page: () => InspirationCategorySearch()),
    GetPage(name: 'cep-category-search', page: () => CepCategorySearch()),
    GetPage(name: 'document-video-search', page: () => DocumentVideoSearch()),
    GetPage(name: 'document-Audio-search', page: () => DocumentAudioSearch()),
    GetPage(name: 'document-ebook-search', page: () => DocumentEbookSearch()),
    GetPage(
        name: 'cep-prime-category-search',
        page: () => CepPrimeCategorySearch()),
    GetPage(name: 'cep-prime', page: () => CepPrime()),
    GetPage(name: 'promo-code-list', page: () => PromoCodeList()),
    GetPage(name: 'renew-package', page: () => RenewPackage()),
    GetPage(name: 'core-steps', page: () => CoreSteps()),
    GetPage(
        name: 'member-core-step-details', page: () => MemberCoreStepDetails()),
    GetPage(name: 'member-core-step-list', page: () => MemberCoreStepList()),
    GetPage(name: 'guest-gift', page: () => GuestGift()),
    GetPage(name: 'gift-member-list', page: () => GiftMemberList()),
    GetPage(name: 'gift-sharing', page: () => GiftSharing()),
    GetPage(name: 'purchase-gift', page: () => PurchaseGift()),
    GetPage(name: 'thanks-page-gift', page: () => ThanksPageGift()),
    GetPage(name: 'test', page: () => Test()),
    GetPage(name: 'test1', page: () => Test1()),
    GetPage(name: 'request-warning-popup', page: () => RequestWarningPopup()),
    GetPage(name: 'something-went-wrong', page: () => SomethingWentWrong()),
  ];
}
