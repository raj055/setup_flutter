import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:permission_handler/permission_handler.dart';

import '../../screens/guest/guest_list.dart';
import '../../services/api.dart';
import '../../services/translator.dart';

class AddGuest extends StatefulWidget {
  @override
  _AddGuestState createState() => _AddGuestState();
}

class _AddGuestState extends State<AddGuest> {
  List<Contact>? _contactsList;

  List<CustomContact> contactsFiltered = [];

  List<CustomContact> _customContacts = [];

  Map<String, Color> contactsColorMap = new Map();

  TextEditingController searchController = new TextEditingController();

  bool isSelected = false;
  var myColor = Colors.white;

  int count = 0;

  List<Map> selectedList = [];

  late PermissionStatus status;

  bool? isPermanentlyDenied;

  Map? userPermission;

  @override
  void initState() {
    super.initState();
    userPermission = Get.arguments;
    // if (isPermanentlyDenied)
    _askPermissions();
  }

  void _askPermissions() async {
    _checkPermission().then((hasGranted) async {
      if (hasGranted) {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          refreshContacts();
        });

        searchController.addListener(
          () {
            filterContacts();
          },
        );
      } else {
        _checkPermission();
      }
    });
  }

  Future<bool> _checkPermission() async {
    status = await Permission.contacts.status;
    if (await Permission.contacts.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      if (status.isGranted) {
        return true;
      } else {
        _checkPermission();
      }
    }

    return false;
  }

  Future<void> refreshContacts() async {
    var contacts =
        (await ContactsService.getContacts(withThumbnails: false, iOSLocalizedLabels: iOSLocalizedLabels)).toList();

    setState(() {
      _contactsList = contacts;

      _customContacts = _contactsList!
          .where(
            (contact) {
              if (contact.phones.length > 0) {
                dynamic phone = contact.phones.first;

                if (phone.value.length >= 10) {
                  return true;
                }
              }
              return false;
            },
          )
          .map((contact) => CustomContact(contact: contact))
          .toList();
    });

    for (final contact in contacts) {
      ContactsService.getAvatar(contact).then(
        (avatar) {
          if (avatar == null) return;
          if (mounted) {
            setState(() => contact.avatar = avatar);
          }
        },
      );
    }
  }

  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(
      RegExp(r'^(\+)|\D'),
      (Match m) {
        return m[0] == "+" ? "+" : "";
      },
    );
  }

  filterContacts() {
    List<Contact> _contacts = [];
    _contacts.addAll(_contactsList!);
    if (searchController.text.isNotEmpty) {
      _contacts.retainWhere(
        (contact) {
          String searchTerm = searchController.text.toLowerCase();
          String contactName = contact.displayName != null ? contact.displayName.toLowerCase() : contact.displayName;
          bool nameMatches = contactName != null ? contactName.contains(searchTerm) : contactName as bool;
          if (nameMatches == true) {
            return true;
          }

          if (contactName != null) {
            String phnFlattened = flattenPhoneNumber(contactName);
            return phnFlattened.contains(searchTerm);
          }

          return contactName != null;
        },
      );

      setState(() {
        contactsFiltered = _contacts.map((contact) => CustomContact(contact: contact)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = searchController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(Translator.get("Add Guest")!),
        actions: <Widget>[
          if (count > 0)
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Center(
                child: Text(
                  count.toString(),
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              if (count > 0)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.grey[200],
                  ),
                  height: 50.0,
                  width: double.infinity,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Wrap(
                        spacing: 6.0,
                        runSpacing: 4.0,
                        children: selectedList.map((selectedContact) {
                          return Chip(
                            // backgroundColor: Colors.primaries[
                            //     Random().nextInt(Colors.primaries.length)],
                            backgroundColor: Colors.white,
                            label: Text(selectedContact['name']),
                            elevation: 10,
                            onDeleted: () {
                              setState(() {
                                _customContacts.map((customContact) {
                                  if (customContact.isChecked &&
                                      selectedContact['name'].toString().toLowerCase() ==
                                          customContact.contact!.displayName.toLowerCase()) {
                                    customContact.isChecked = !customContact.isChecked;
                                    selectedList.remove(selectedContact);
                                    count = selectedList.length;
                                  }
                                }).toList();
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                padding: EdgeInsets.all(5.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                      labelText: Translator.get('Search'),
                      border: new OutlineInputBorder(borderSide: new BorderSide(color: Theme.of(context).primaryColor)),
                      prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor)),
                ),
              ),
              Expanded(
                child: _contactsList != null
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: isSearching == true ? contactsFiltered.length : _customContacts.length,
                        itemBuilder: (BuildContext context, int index) {
                          CustomContact? c =
                              isSearching == true ? contactsFiltered[index] : _customContacts.elementAt(index);

                          String? phnFlattened = c.contact!.phones.length > 0
                              ? flattenPhoneNumber(c.contact!.phones.elementAt(0).value)
                              : null;

                          return ListTile(
                            selected: isSelected,
                            onTap: () {
                              _checkContactList(c, phnFlattened, index);
                            },
                            trailing: _checkContact(c, phnFlattened, index),
                            leading: (c.contact!.avatar != null && c.contact!.avatar.length > 0)
                                ? CircleAvatar(backgroundImage: MemoryImage(c.contact!.avatar))
                                : CircleAvatar(child: Text(c.contact!.initials())),
                            title: Text(c.contact!.displayName ?? ""),
                            subtitle: Text(phnFlattened ?? ""),
                          );
                        },
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CircularProgressIndicator(),
                            if (userPermission != null && !userPermission!["isPermanentlyDenied"]) ...[
                              RaisedButton(
                                color: Theme.of(context).primaryColor,
                                textColor: Colors.white,
                                onPressed: () {
                                  if (status.isDenied) {
                                    Get.back();
                                    _askPermissions();
                                  } else if (status.isPermanentlyDenied) {
                                    openAppSettings().then((value) {
                                      Get.back();
                                    });
                                  }
                                },
                                child: Text('Contact Request '),
                              ),
                              Text('Please Accept Contact Permission Request'),
                            ],
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(10),
        child: RaisedButton(
          color: Theme.of(context).primaryColor,
          padding: EdgeInsets.all(15),
          textColor: Colors.white,
          onPressed: () {
            Map guestData = {
              'guests': selectedList,
            };
            Api.http.post('add-bulk-guests', data: guestData).then(
              (response) async {
                if (response.data['status']) {
                  Navigator.pop(context);
                  Get.offAllNamed("home");
                  Get.toNamed("guest-list");
                }
                GetBar(
                  backgroundColor: response.data['status'] ? Colors.green : Colors.red,
                  duration: Duration(seconds: 3),
                  message: response.data['message'],
                ).show();
              },
            ).catchError(
              (error) {
                if (error.response.statusCode == 422) {
                  GetBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                    message: Translator.get("Contacts Not Add")!,
                  ).show();
                } else if (error.response.statusCode == 401) {
                  GetBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 5),
                    message: error.response.data['errors'],
                  ).show();
                }
              },
            );
          },
          child: Text(Translator.get("Add Guests")!.toUpperCase()),
        ),
      ),
    );
  }

  void _checkContactList(CustomContact c, String? phnFlattened, int index) {
    setState(() {
      c.isChecked = !c.isChecked;

      if (c.isChecked) {
        setState(() {
          if (selectedList.length == 0) {
            selectedList.add(
              {"name": c.contact!.displayName, "mobile": phnFlattened},
            );
          } else {
            int index = selectedList.indexWhere((contact) => contact["mobile"] == phnFlattened);

            if (index == -1) {
              selectedList.add(
                {"name": c.contact!.displayName, "mobile": phnFlattened},
              );
            }
          }
          count = selectedList.length;
        });
      } else if (!c.isChecked) {
        for (int i = 0; i < selectedList.length; i++) {
          if (phnFlattened == selectedList[i]['mobile']) {
            selectedList.removeAt(i);
          }
        }
        count = selectedList.length;
      }
    });
  }

  Widget _checkContact(CustomContact c, String? phnFlattened, int index) {
    return Checkbox(
      activeColor: Colors.blue,
      value: c.isChecked,
      onChanged: (val) {
        _checkContactList(c, phnFlattened, index);
      },
    );
  }
}

class Item {
  String name;
  String mobile;

  Item(this.name, this.mobile);
}

class CustomContact {
  final Contact? contact;
  bool isChecked;

  CustomContact({
    this.contact,
    this.isChecked = false,
  });
}
