import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:nb_utils/nb_utils.dart';

// type for litview Builder
typedef Widget ListItemBuilder(dynamic itemData, int index);

//type for Gridview Builder
typedef Widget GridItemBuilder(dynamic itemData, int index);

const fontThin = 'Thin';
const fontLight = 'Light';
const fontRegular = 'Regular';
const fontMedium = 'Medium';
const fontSemibold = 'Semi-Bold';
const fontBold = 'Bold';

/* font sizes*/
const textSizeExtraSmall = 10.0;
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

Color colorPrimary = Color(int.parse(DotEnv.env['PRIMARY_COLOR']!));
Color colorAccent = Color(int.parse(DotEnv.env['ACCENT_COLOR']!));
const textColorPrimary = Color(0XFF333333);
const textColorSecondary = Color(0XFF747474);
const colorPrimary_light = Color(0XFFE9E9E9);
const colorPrimaryDark = Color(0XFF212121);

const view_color = Color(0XFFDADADA);

const app_background = Color(0XFFE9E9E9);
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
const white_color = Color(0XFFffffff);

const profileImage = 'assets/images/users.png';
const logo = "assets/images/logo.png";
const logo1 = "assets/images/logo1.png";
const noImage = "assets/images/placeholder.png";
const rocket = "assets/images/rocket.gif";
// const login_bg = 'assets/images/login_bg.svg';
const menu = "assets/images/menu.svg";
const cart = "assets/images/cart.svg";

int cartCount = 0;

ListView listviewBuilder(
  ListItemBuilder itemBuilder, {
  @required List? items,
  EdgeInsets? padding,
  int? itemCount,
  bool? shrinkWrap,
  Axis scrollDirection = Axis.vertical,
  ScrollPhysics? scrollPhysics,
}) {
  return ListView.builder(
    itemCount: (items != null) ? items.length : itemCount,
    padding: padding,
    scrollDirection: scrollDirection,
    shrinkWrap: (shrinkWrap != null) ? shrinkWrap : true,
    itemBuilder: (BuildContext ctxt, int index) {
      return index < items!.length ? itemBuilder(items[index], index) : SizedBox.shrink();
    },
    physics: scrollPhysics,
  );
}

GridView gridviewBuilder(List? items, GridItemBuilder itemBuilder,
    {ScrollPhysics? physics,
    EdgeInsets? padding,
    bool? shrinkWrap,
    Axis scrollDirection = Axis.vertical,
    @required int? numberOfColumns,
    @required double? verticleSpacing,
    @required double? horizontalSpacing,
    bool? primary,
    double? childAspectRatio}) {
  return GridView.builder(
      itemCount: items!.length,
      padding: padding,
      primary: primary,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: numberOfColumns!,
        crossAxisSpacing: horizontalSpacing!,
        mainAxisSpacing: verticleSpacing!,
        childAspectRatio: childAspectRatio != null ? childAspectRatio : 10 / 10,
      ),
      scrollDirection: scrollDirection,
      shrinkWrap: (shrinkWrap != null) ? shrinkWrap : true,
      itemBuilder: (BuildContext ctxt, int index) {
        return index < items.length ? itemBuilder(items[index], index) : SizedBox.shrink();
      });
}

AppBarTheme appBarTheme() {
  return AppBarTheme(
    color: white,
    elevation: 1,
    textTheme: TextTheme(
      headline6: TextStyle(
        color: Colors.black,
        fontFamily: fontSemibold,
        fontSize: 16,
      ),
    ),
    actionsIconTheme: IconThemeData(color: Colors.black),
    iconTheme: IconThemeData(color: Colors.black),
  );
}

String capitalize(String string) {
  if (string == null) {
    throw ArgumentError("string: $string");
  }

  if (string.isEmpty) {
    return string;
  }

  return string[0].toUpperCase() + string.substring(1);
}

Widget text(
  String text, {
  var fontSize = textSizeMedium,
  textColor = black,
  var fontFamily = fontRegular,
  var isCentered = false,
  var maxLine = 1,
  var textAllCaps = false,
  var isLongText = false,
  var overflow,
  var decoration,
  var fontweight,
}) {
  return Text(
    textAllCaps ? text.toUpperCase() : text,
    textAlign: isCentered ? TextAlign.center : TextAlign.start,
    maxLines: isLongText ? null : maxLine,
    style: TextStyle(fontFamily: fontFamily, fontSize: fontSize, color: textColor, height: 1.5, decoration: decoration, fontWeight: fontweight),
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
          child: text(
            label,
            textColor: primary,
            fontFamily: fontSemibold,
            isLongText: true,
          ),
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

TextStyle primaryTextStyle1({
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

Divider view() {
  return Divider(
    color: textColorSecondary,
    height: 0.5,
  );
}

BoxDecoration boxDecoration({
  double radius = 2,
  Color? color = Colors.transparent,
  Color? bgColor = white,
  var showShadow = false,
}) {
  return BoxDecoration(
    color: bgColor,
    boxShadow: showShadow ? [BoxShadow(color: Color(0XFFF2F2F2), blurRadius: 10, spreadRadius: 2)] : [BoxShadow(color: Colors.transparent)],
    border: Border.all(color: color!),
    borderRadius: BorderRadius.all(Radius.circular(radius)),
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
        counterText: "",
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

Widget formField(
  context,
  hint, {
  isEnabled = true,
  isDummy = false,
  TextEditingController? controller,
  isPasswordVisible = false,
  isPassword = false,
  keyboardType = TextInputType.text,
  FormFieldValidator<String>? validator,
  onSaved,
  textInputAction = TextInputAction.next,
  ValueChanged<String?>? onChanged,
  List<TextInputFormatter>? inputFormatters,
  FocusNode? focusNode,
  FocusNode? nextFocus,
  IconData? suffixIcon,
  IconData? prefixIcon,
  maxLine = 1,
  readOnly = false,
  suffixIconSelector,
  Widget? suffixWidget,
  maxLength,
  TextCapitalization? textCapitalization,
}) {
  return TextFormField(
    controller: controller,
    obscureText: isPassword ? isPasswordVisible : false,
    cursorColor: colorPrimary,
    maxLines: maxLine,
    keyboardType: keyboardType,
    validator: validator,
    onSaved: onSaved,
    readOnly: readOnly,
    textCapitalization: TextCapitalization.none,
    onChanged: onChanged,
    textInputAction: textInputAction,
    inputFormatters: inputFormatters,
    focusNode: focusNode,
    maxLength: maxLength,
    onFieldSubmitted: (arg) {
      if (nextFocus != null) {
        FocusScope.of(context).requestFocus(nextFocus);
      }
    },
    decoration: InputDecoration(
      focusedBorder: UnderlineInputBorder(
        borderRadius: BorderRadius.circular(spacing_standard),
        borderSide: BorderSide(color: Colors.transparent),
      ),
      enabledBorder: UnderlineInputBorder(
        borderRadius: BorderRadius.circular(spacing_standard),
        borderSide: BorderSide(color: Colors.transparent),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 15),
      counterText: "",
      filled: true,
      fillColor: Color(0xFFf7f7f7),
      hintText: hint,
      hintStyle: TextStyle(fontSize: textSizeMedium, color: textColorSecondary),
      prefixIcon: Icon(
        prefixIcon,
        color: textColorSecondary,
        size: 20,
      ),
      suffixIcon: isPassword
          ? GestureDetector(
              onTap: suffixIconSelector,
              child: new Icon(
                suffixIcon,
                color: textColorSecondary,
                size: 20,
              ),
            )
          : suffixWidget,
    ),
    style: TextStyle(
      fontSize: textSizeLargeMedium,
      color: isDummy ? Colors.transparent : colorPrimaryDark,
      fontFamily: fontRegular,
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
      labelStyle: primaryTextStyle1(
        fontSize: 16,
        color: textColorPrimary.withOpacity(0.7),
        fontFamily: fontMedium,
      ),
      // prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      counterText: '',
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
  Color? customColor;

  CustomButton({
    @required this.textContent,
    @required this.onPressed,
    this.isStroked = false,
    this.customColor,
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
          fontFamily: fontSemibold,
          textAllCaps: true,
        ),
        decoration: widget.isStroked
            ? boxDecoration(
                bgColor: Colors.transparent,
                color: widget.customColor != null ? widget.customColor! : colorPrimary,
                radius: 5,
              )
            : boxDecoration(
                bgColor: widget.customColor != null ? widget.customColor! : colorPrimary,
                radius: 5,
              ),
      ),
    );
  }
}

Widget emptyWidget(BuildContext context, String image, String title, String desc, {bool showRetry = false, Function? onRetry}) {
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
    gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [gradientColor1, gradientColor2]),
    boxShadow: showShadow ? [BoxShadow(color: shadow_color, blurRadius: 10, spreadRadius: 2)] : [BoxShadow(color: Colors.transparent)],
    border: Border.all(color: color),
    borderRadius: BorderRadius.all(Radius.circular(radius)),
  );
}
