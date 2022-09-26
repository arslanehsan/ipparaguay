// import 'dart:io';
//
// import 'package:flutter/cupertino.dart';
// import 'package:webview_flutter/webview_flutter.dart';
//
// class Home extends StatefulWidget {
//   const Home({Key? key}) : super(key: key);
//
//   @override
//   State<Home> createState() => _HomeState();
// }
//
// class _HomeState extends State<Home> {
//   @override
//   void initState() {
//     super.initState();
//     if (Platform.isAndroid) WebView.platform = AndroidWebView();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return const SafeArea(
//       child: WebView(
//         initialUrl: 'https://ipparaguay.com.py/',
//         javascriptMode: JavascriptMode.unrestricted,
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Homepage extends StatefulWidget {
  @override
  HomepageState createState() => HomepageState();
}

class HomepageState extends State<Homepage> {
  late WebViewController _controller;

  final Completer<WebViewController> _controllerCompleter =
      Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  bool isLoading = true;
  final _key = UniqueKey();

  Future<void> reloadPage() async {
    print('m called');
    await _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => _goBack(context),
        child: Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: reloadPage,
              child: Stack(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: WebView(
                      key: _key,
                      initialUrl: 'https://ipparaguay.com.py/',
                      javascriptMode: JavascriptMode.unrestricted,
                      onPageFinished: (finish) {
                        setState(() {
                          isLoading = false;
                        });
                      },
                      onWebViewCreated: (WebViewController webViewController) {
                        _controllerCompleter.future
                            .then((value) => _controller = value);
                        _controllerCompleter.complete(webViewController);
                      },
                    ),
                  ),
                  isLoading
                      ? Center(
                          child: SizedBox(
                            height: 60,
                            width: 60,
                            child: const CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                            // child: Image.asset('images/loader.gif'),
                          ),
                        )
                      : Stack(),
                ],
              ),
            ),
          ),
        ));
  }

  Future<bool> _goBack(BuildContext context) async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return Future.value(false);
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Do you want to exit'),
                actions: <Widget>[
                  MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('No'),
                  ),
                  MaterialButton(
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                    child: Text('Yes'),
                  ),
                ],
              ));
      return Future.value(true);
    }
  }
}
