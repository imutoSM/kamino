import 'package:flutter/material.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/main.dart';

class TitleText extends Text {

  TitleText(String text, {
    double fontSize : 18,
    Color textColor,
    bool allowOverflow = false,
    TextAlign textAlign,
    int maxLines
  }) : super(
    text,
    overflow: (allowOverflow
        ? (maxLines == null ? null : TextOverflow.ellipsis)
        : TextOverflow.ellipsis),
    style: TextStyle(
      fontFamily: 'GlacialIndifference',
      fontSize: fontSize,
      color: textColor,
    ),
    textAlign: textAlign,
    maxLines: (allowOverflow ? maxLines : 1),
  );

}

class SubtitleText extends StatelessWidget {

  final String text;
  final EdgeInsetsGeometry padding;

  SubtitleText(this.text, {
    Key key,
    this.padding = const EdgeInsets.symmetric(horizontal: 5, vertical: 10)
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      child: Text(text.toUpperCase(), style: TextStyle(
        fontSize: 14,
        fontFamily: 'GlacialIndifference',
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
        color: Theme.of(context).primaryTextTheme.display3.color,
      ), textAlign: TextAlign.start),
      padding: padding,
    );
  }

}

class ConcealableText extends StatefulWidget {

  final String text;
  final String revealLabel;
  final String concealLabel;
  final Color color;
  final Color revealLabelColor;
  final TextOverflow overflowType;

  final int maxLines;

  ConcealableText(this.text, {
    @required this.revealLabel,
    @required this.concealLabel,
    @required this.maxLines,
    this.color,
    this.revealLabelColor,
    this.overflowType = TextOverflow.fade
  });

  @override
  State<StatefulWidget> createState() => ConcealableTextState();
}

class ConcealableTextState extends State<ConcealableText> {

  bool isConcealed = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LayoutBuilder(builder: (context, size){
          var textSpan = TextSpan(
            text: widget.text,
            style: Theme.of(context).primaryTextTheme.body1.copyWith(
              color: widget.color
            )
          );

          var textPainter = TextPainter(
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
            maxLines: widget.maxLines,
            textAlign: TextAlign.start,
            textDirection: Directionality.of(context),
            text: textSpan
          );

          textPainter.layout(maxWidth: size.maxWidth);
          var exceeded = textPainter.didExceedMaxLines;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text.rich(
                textSpan,
                overflow: widget.overflowType,
                maxLines: (isConcealed ? widget.maxLines : null)
              ),

              (exceeded ?
                GestureDetector(
                  onTap: (){
                    setState((){
                      isConcealed = !isConcealed;
                    });
                  },
                  child: Padding(
                    padding: isConcealed ? EdgeInsets.only(top: 5.0) : EdgeInsets.only(top: 10.0),
                    child: Text(
                      isConcealed ? widget.revealLabel : widget.concealLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: widget.revealLabelColor
                      )
                    )
                  ),
                )
                : Container()
              )
            ]
          );
        })
      ],
    );
  }

}

class VerticalIconButton extends StatelessWidget {

  Color backgroundColor;
  Color foregroundColor;
  Widget icon;
  Widget title;
  EdgeInsetsGeometry padding;
  BorderRadiusGeometry borderRadius;
  GestureTapCallback onTap;


  VerticalIconButton({
    @required this.icon,
    @required this.title,
    @required this.onTap,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
    this.borderRadius
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: borderRadius ?? BorderRadius.circular(5),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: borderRadius ?? BorderRadius.circular(5),
        onTap: onTap,
        child: Container(
          padding: padding,
          child: Column(
            children: <Widget>[
              icon,
              Container(child: title, margin: EdgeInsets.only(top: 10))
            ]
          )
        )
      )
    );
  }

}

class OfflineMixin extends StatefulWidget {

  final Function reloadAction;

  OfflineMixin({
    this.reloadAction
  });

  @override
  State<StatefulWidget> createState() => OfflineMixinState();

}

class OfflineMixinState extends State<OfflineMixin> {

  bool _isLoading;

  OfflineMixinState() {
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.offline_bolt, size: 48, color: Colors.grey),
              Container(padding: EdgeInsets.symmetric(vertical: 10)),
              TitleText(S.of(context).youre_offline, fontSize: 24),
              Container(padding: EdgeInsets.symmetric(vertical: 3)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                  S.of(context).appname_failed_to_connect_to_the_internet(appName),
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16
                  ),
                ),
              ),

              widget.reloadAction != null ? Container(
                padding: EdgeInsets.only(top: 10),
                child: !_isLoading ? FlatButton(
                  child: Text(S.of(context).reload.toUpperCase()),
                  textColor: Theme.of(context).primaryColor,
                  onPressed: () async {
                    _isLoading = true;
                    setState((){});
                    await Future.delayed(Duration(seconds: 3));
                    await widget.reloadAction();
                    setState((){});
                    _isLoading = false;
                  },
                ) : Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: CircularProgressIndicator(),
                ),
              ) : Container()
            ],
          ),
        ),
      ),
    );
  }

}

class ErrorLoadingMixin extends StatelessWidget {

  final String errorMessage;

  ErrorLoadingMixin({
    this.errorMessage
  });

  @override
  Widget build(BuildContext context) {
    if(errorMessage == null) S.of(context).an_error_occurred_whilst_loading_this_page;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.error, size: 48, color: Colors.grey),
              Container(padding: EdgeInsets.symmetric(vertical: 10)),
              TitleText(S.of(context).an_error_occurred, fontSize: 24),
              Container(padding: EdgeInsets.symmetric(vertical: 3)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                  errorMessage,
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}