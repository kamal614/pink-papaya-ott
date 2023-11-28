import 'package:dtlive/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TestTVHome extends StatefulWidget {
  const TestTVHome({super.key});

  @override
  State<TestTVHome> createState() => _TestTVHomeState();
}

class _TestTVHomeState extends State<TestTVHome> {
  @override
  void initState() {
    firstFn();
    // TODO: implement initState
    super.initState();
  }

  firstFn() {
    openDetailPage(
      "videodetail",
      253,
      0,
      1,
      18,
    );
  }

  openDetailPage(String pageName, int videoId, int upcomingType, int videoType,
      int typeId) async {
    debugPrint("pageName ==========> $pageName");
    debugPrint("videoId ==========> $videoId");
    debugPrint("videoType ==========> $videoType");
    debugPrint("typeId ==========> $typeId");
    if (!mounted) return;
    Utils.openDetails(
      context: context,
      videoId: videoId,
      upcomingType: upcomingType,
      videoType: videoType,
      typeId: typeId,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
