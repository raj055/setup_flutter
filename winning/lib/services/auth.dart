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
  static bool? _cep;
  static bool? _profile;
  static StreamController? userStreamController;
  static Stream? userStream;
  static String? _userName;

  static Future<void> initialize() async {
    _user = await (Storage.get('user'));
    _token = await (Storage.get('token'));
    _currentPackage = await (Storage.get('current_package'));
    _packageName = await (Storage.get('package'));
    _cep = await (Storage.get('cep'));
    _profile = await (Storage.get('profile'));
    _packages = await (Storage.get("packages"));
    _userName = await (Storage.get("userName"));
    _isLoggedIn = _token != null;
    _openUserStream();
  }

  static bool? check() {
    return _isLoggedIn!;
  }

  static Map? user() {
    return _user!;
  }

  static List? packages() {
    return _packages!;
  }

  static String? token() {
    return _token;
  }

  static int? currentPackage() {
    return _currentPackage!;
  }

  static String? packageName() {
    return _packageName!;
  }

  static String? userName() {
    return _userName!;
  }

  static bool? cep() {
    return _cep!;
  }

  static bool? profile() {
    return _profile!;
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

  static Future<bool> setCep({bool? cep}) async {
    _cep = cep;
    await Storage.set('cep', cep);
    return true;
  }

  static Future<bool> setProfile(bool? profile) async {
    await Storage.set('profile', profile);
    return true;
  }

  static Future<bool> setUsername(String userName) async {
    await Storage.set('userName', userName);
    return true;
  }

  static Future<bool> login(
      {Map? user, String? token, int? currentPackage, String? packageName, List? packages, bool? cep, profile}) async {
    _user = user;
    _token = token;
    _currentPackage = currentPackage;
    _packageName = packageName;
    _cep = cep;
    _profile = profile;
    _packages = packages;
    _isLoggedIn = true;
    await Storage.set('user', user);
    await Storage.set('token', token);
    await Storage.set('current_package', currentPackage);
    await Storage.set('package', packageName);
    await Storage.set('packages', packages);
    await Storage.set('cep', cep);
    await Storage.set('profile', profile);
    _openUserStream();
    return true;
  }

  static Future<bool> logout() async {
    _user = null;
    _token = null;
    _currentPackage = null;
    _cep = null;
    _packages = null;
    _isLoggedIn = false;

    await Storage.delete('user');
    await Storage.delete('token');
    await Storage.delete('packages');
    await Storage.delete('current_package');
    await Storage.delete('package');
    await Storage.delete('cep');
    await Storage.delete('profile');
    await Storage.delete('packages');

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
