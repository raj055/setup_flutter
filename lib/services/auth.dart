import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'storage.dart';

class Auth {
  static bool? _isLoggedIn;
  static Map? _user;
  static List? _packages;
  static String? _packageName;
  static String? _token;
  static int? _currentPackage;
  static int? _memberId;
  static bool? _isVendor;
  static int? _isMemberStatus;
  static bool? _profile;
  static StreamController? userStreamController;
  static Stream? userStream;
  static String? _userName;
  static bool? isMLMLoggedIn;
  static Map? _userMLM;
  static String? _tokenMLM;

  static Future<void> initialize() async {
    _user = await Storage.get('user');
    _token = await Storage.get('token');
    _currentPackage = await Storage.get('current_package');
    _memberId = await Storage.get('member_id');
    _packageName = await Storage.get('package');
    _isVendor = await Storage.get('isVendor');
    _isMemberStatus = await Storage.get('isMemberStatus');
    _profile = await Storage.get('profile');
    _packages = await Storage.get("packages");
    _userName = await Storage.get("userName");
    _isLoggedIn = _token != null;

    _userMLM = await Storage.get('userMLM');
    _tokenMLM = await Storage.get('tokenMLM');
    isMLMLoggedIn = _tokenMLM != null;

    _openUserStream();
  }

  static bool? check() {
    return _isLoggedIn;
  }

  static Map? user() {
    return _user;
  }

  static Map? userMLM() {
    return _userMLM;
  }

  static List? packages() {
    return _packages;
  }

  static token() {
    return _token;
  }

  static String? tokenMLM() {
    return _tokenMLM;
  }

  static int? currentPackage() {
    return _currentPackage;
  }

  static int? memberId() {
    return _memberId;
  }

  static String? packageName() {
    return _packageName;
  }

  static String? userName() {
    return _userName;
  }

  static bool? isVendor() {
    return _isVendor;
  }

  static int? isMemberStatus() {
    return _isMemberStatus;
  }

  static bool? profile() {
    return _profile;
  }

  static Future<bool> setPackageName(String packageName) async {
    await Storage.set('package', packageName);
    return true;
  }

  static Future<bool> setCurrentPackage({int? package}) async {
    _currentPackage = package;
    await Storage.set('current_package', package);
    return true;
  }

  static Future<bool> setMemberId({int? memberId}) async {
    _memberId = memberId;
    await Storage.set('member_id', memberId);
    return true;
  }

  static Future<bool> setVendor({bool? isVendor}) async {
    _isVendor = isVendor;
    await Storage.set('isVendor', isVendor);
    return true;
  }

  static Future<bool> setMemberStatus({int? isMemberStatus}) async {
    _isMemberStatus = isMemberStatus;
    await Storage.set('isMemberStatus', isMemberStatus);
    return true;
  }

  static Future<bool> setProfile(bool profile) async {
    await Storage.set('profile', profile);
    return true;
  }

  static Future<bool> setUsername(String userName) async {
    await Storage.set('userName', userName);
    return true;
  }

  static Future<bool> updateUser(Map? user) async {
    if (await Storage.get('user') != null) {
      _user = user;
      return await Storage.set('user', user);
    } else {
      return false;
    }
  }

  static Future<bool> login({Map? user, String? token, int? currentPackage, String? packageName, List? packages, bool? isVendor, profile}) async {
    _user = user;
    _token = token;
    _currentPackage = currentPackage;
    _packageName = packageName;
    _isVendor = isVendor;
    _profile = profile;
    _packages = packages;
    _isLoggedIn = true;
    await Storage.set('user', user);
    await Storage.set('token', token);
    await Storage.set('current_package', currentPackage);
    await Storage.set('package', packageName);
    await Storage.set('packages', packages);
    await Storage.set('isVendor', isVendor);
    await Storage.set('profile', profile);
    _openUserStream();
    return true;
  }

  static Future<bool> logout() async {
    _user = null;
    _token = null;
    _currentPackage = null;
    _memberId = null;
    _isVendor = null;
    _isMemberStatus = null;
    _packages = null;
    _isLoggedIn = false;

    await Storage.delete('user');
    await Storage.delete('token');
    await Storage.delete('packages');
    await Storage.delete('current_package');
    await Storage.delete('isMemberStatus');
    await Storage.delete('package');
    await Storage.delete('isVendor');
    await Storage.delete('profile');
    await Storage.delete('packages');

    await _closeUserStream();

    return true;
  }

  static Future<bool> loginMLM({Map? userMLM, String? tokenMLM}) async {
    _userMLM = userMLM;
    _tokenMLM = tokenMLM;
    isMLMLoggedIn = true;
    await Storage.set('userMLM', userMLM);
    await Storage.set('tokenMLM', tokenMLM);
    _openUserStream();
    return true;
  }

  static Future<bool> logoutMLM() async {
    _userMLM = null;
    _tokenMLM = null;
    isMLMLoggedIn = false;
    // pageName = "morado-ecommerce";
    // pageData = null;

    await Storage.delete('userMLM');
    await Storage.delete('tokenMLM');

    await _closeUserStream();

    return true;
  }

  static void _openUserStream() {
    if (userStreamController == null) {
//      userStreamController = StreamController();
      userStreamController = BehaviorSubject();
      userStream = userStreamController!.stream;
    }

    if (_user != null) {
      userStreamController!.add(_user);
    }
  }

  static Future<void> _closeUserStream() async {
    await userStreamController!.close();
    userStream = null;
    userStreamController = null;
  }
}
