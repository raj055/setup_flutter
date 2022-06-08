import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const fontRegular = 'Regular';
const fontMedium = 'Medium';
const fontSemibold = 'Semibold';
const fontBold = 'Bold';

/* font sizes*/
const textSizeSmall = 12.0;
const textSizeSMedium = 14.0;
const textSizeMedium = 16.0;
const textSizeLargeMedium = 18.0;
const textSizeNormal = 20.0;
const textSizeLarge = 22.0;
const textSizeXLarge = 30.0;

/* margin */
const spacing_control_half = 2.0;
const spacing_control = 4.0;
const spacing_standard = 8.0;
const spacing_middle = 10.0;
const spacing_standard_new = 16.0;
const spacing_large = 24.0;
const spacing_xlarge = 32.0;
const spacing_xxLarge = 40.0;
Color colorPrimary = Color(int.parse(dotenv.env['PRIMARY_COLOR']!));
Color colorAccent = Color(int.parse(dotenv.env['ACCENT_COLOR']!));
const textColorPrimary = Color(0XFF333333);
const textColorSecondary = Color(0XFF747474);
const colorPrimary_light = Color(0XFFFFEEEE);
const colorPrimaryDark = Color(0XFF212121);

const view_color = Color(0XFFDADADA);

const icon_color = Color(0XFF747474);
const selected_tab = Color(0XFFFCE9E9);
const primary = Color(0Xff0047ba);
const red = Color(0XFFF10202);
const blue = Color(0XFF1D36C0);
const green = Color(0XFF4CAF50);
const edit_text_background = Color(0XFFE8E8E8);
const shadow = Color(0X70E2E2E5);
const shadow_color = Color(0X95E9EBF0);
const color_primary_light = Color(0XFFFCE8E8);
const bg_bottom_sheet = Color(0XFFFFF1F1);
const white = Color(0XFFffffff);

const profileImage = 'assets/images/users.png';
const logo = "assets/images/logo.png";
const noImage = "assets/images/placeholder.png";
const rocket = "assets/images/rocket.gif";
// const login_bg = 'assets/images/login_bg.svg';

AppBarTheme appBarTheme() {
  return AppBarTheme(
    brightness: Brightness.dark,
    systemOverlayStyle: SystemUiOverlayStyle(
      // systemNavigationBarColor: Colors.blue, // navigation bar color
      // statusBarColor: Colors.pink,
      statusBarIconBrightness: Brightness.dark,
      // statusBarBrightness:
      // systemNavigationBarIconBrightness: Brightness.light, // status bar color
    ),
    color: colorPrimary,
    elevation: 0,
    textTheme: TextTheme(
      headline6: TextStyle(
        color: white,
        fontFamily: fontBold,
        fontSize: 18,
      ),
    ),
    actionsIconTheme: IconThemeData(color: white),
    iconTheme: IconThemeData(color: white),
  );
}

String capitalize(String? string) {
  if (string == null) {
    throw ArgumentError("string: $string");
  }

  if (string.isEmpty) {
    return string;
  }

  return string[0].toUpperCase() + string.substring(1);
}

Widget text(
  String? text, {
  var fontSize = textSizeMedium,
  textColor = textColorSecondary,
  var fontFamily = fontRegular,
  var fontWeight,
  var isCentered = false,
  var maxLine = 1,
  var textAllCaps = false,
  var isLongText = false,
  var overflow,
}) {
  return Text(
    textAllCaps ? text!.toUpperCase() : text!,
    textAlign: isCentered ? TextAlign.center : TextAlign.start,
    maxLines: isLongText ? null : maxLine,
    style: TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      color: textColor,
      height: 1.5,
      fontWeight: fontWeight,
    ),
    overflow: overflow,
  );
}

Widget rowHeading(var label, var subLabel) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
    child: Row(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: text(label, textColor: primary, fontFamily: fontSemibold),
        ),
        Expanded(
          flex: 3,
          child: text(
            subLabel,
            textColor: textColorSecondary,
            isLongText: true,
          ),
        )
      ],
    ),
  );
}

Divider view() {
  return Divider(
    color: textColorSecondary,
    height: 0.5,
  );
}

BoxDecoration boxDecoration({
  double radius = 2,
  Color color = Colors.transparent,
  Color? bgColor = white,
  var showShadow = false,
}) {
  return BoxDecoration(
    color: bgColor,
    boxShadow: showShadow
        ? [BoxShadow(color: Color(0XFFF2F2F2), blurRadius: 10, spreadRadius: 2)]
        : [BoxShadow(color: Colors.transparent)],
    border: Border.all(color: color),
    borderRadius: BorderRadius.all(Radius.circular(radius)),
  );
}

TextStyle primaryTextStyle({
  double? fontSize,
  Color color = textColorPrimary,
  FontWeight weight = FontWeight.normal,
  String? fontFamily,
  double? letterSpacing,
}) {
  return TextStyle(
    fontSize: fontSize,
    color: color,
    fontWeight: weight,
    fontFamily: fontFamily,
    letterSpacing: letterSpacing,
  );
}

Container inputBoxStyle(
  var hintText, {
  isPassword = false,
  bool readonly = false,
  bool? obscureText,
  TextEditingController? controller,
  FormFieldSetter<String>? onSaved,
  FormFieldValidator<String>? validator,
  int? maxLength,
  ValueChanged<String>? onChanged,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
  Widget? suffixIcon,
  Widget? prefixIcon,
  GestureTapCallback? onTap,
}) {
  return Container(
    decoration: boxDecoration(radius: 6, showShadow: false, bgColor: white),
    child: TextFormField(
      style: TextStyle(fontSize: textSizeMedium, fontFamily: fontRegular),
      readOnly: readonly,
      obscureText: isPassword,
      controller: controller,
      validator: validator,
      onSaved: onSaved,
      onChanged: onChanged,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      cursorColor: colorPrimary,
      onTap: onTap,
      decoration: InputDecoration(
        isDense: true,
        hintText: hintText,
        filled: true,
        fillColor: white,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: white, width: 0.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: white, width: 0.0),
        ),
      ),
    ),
  );
}

floatingInput(
  String hintText, {
  isPassword = false,
  bool readonly = false,
  bool? obscureText,
  TextEditingController? controller,
  FormFieldSetter<String>? onSaved,
  FormFieldValidator<String>? validator,
  int? maxLength,
  ValueChanged<String>? onChanged,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
  Widget? suffixIcon,
  Widget? prefixIcon,
  int maxLines = 1,
  GestureTapCallback? onTap,
}) {
  return TextFormField(
    readOnly: readonly,
    obscureText: isPassword,
    controller: controller,
    validator: validator,
    onSaved: onSaved,
    onChanged: onChanged,
    maxLength: maxLength,
    inputFormatters: inputFormatters,
    keyboardType: keyboardType,
    cursorColor: colorPrimary,
    onTap: onTap,
    decoration: InputDecoration(
      labelText: hintText,
      isDense: true,
      labelStyle: primaryTextStyle(
        fontSize: textSizeMedium,
        color: textColorPrimary.withOpacity(0.7),
        fontFamily: fontMedium,
      ),
      // prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
    ),
    maxLines: maxLines,
  );
}

class CustomButton extends StatefulWidget {
  var textContent;
  VoidCallback? onPressed;
  var isStroked = false;

  CustomButton({
    required this.textContent,
    required this.onPressed,
    this.isStroked = false,
  });

  @override
  CustomButtonState createState() => CustomButtonState();
}

class CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 10, 16, 12),
        alignment: Alignment.center,
        child: text(
          widget.textContent,
          textColor: widget.isStroked ? colorPrimary : white,
          isCentered: true,
          fontFamily: fontMedium,
          textAllCaps: true,
        ),
        decoration: widget.isStroked
            ? boxDecoration(bgColor: Colors.transparent, color: colorPrimary)
            : boxDecoration(bgColor: colorPrimary, radius: 5),
      ),
    );
  }
}

// Widget visible(bool visible) => visible ? visible : SizedBox();

Widget emptyWidget(BuildContext context, String image, String title, String desc,
    {bool showRetry = false, Function? onRetry}) {
  return Container(
    color: white,
    constraints: BoxConstraints(maxWidth: 500.0),
    height: MediaQuery.of(context).size.height,
    child: Stack(
      children: [
        Image.asset(
          image,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.fitWidth,
        ),
        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: Container(
            decoration: boxDecoration(
              radius: 10,
              showShadow: true,
              bgColor: Colors.grey[200]!,
            ),
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                text(
                  title,
                  textColor: colorPrimaryDark,
                  fontFamily: fontBold,
                  fontSize: textSizeLargeMedium,
                  maxLine: 2,
                ),
                SizedBox(height: 5),
                text(
                  desc,
                  isCentered: true,
                  isLongText: true,
                ),
              ],
            ),
          ),
        )
      ],
    ),
  );
}

BoxDecoration gradientBoxDecoration(
    {double radius = spacing_middle,
    Color color = Colors.transparent,
    Color gradientColor2 = white,
    Color gradientColor1 = white,
    var showShadow = false}) {
  return BoxDecoration(
    gradient:
        LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [gradientColor1, gradientColor2]),
    boxShadow: showShadow
        ? [BoxShadow(color: shadow_color, blurRadius: 10, spreadRadius: 2)]
        : [BoxShadow(color: Colors.transparent)],
    border: Border.all(color: color),
    borderRadius: BorderRadius.all(Radius.circular(radius)),
  );
}
