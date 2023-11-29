import 'package:dtlive/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TestTVHome extends StatefulWidget {
  int videoId;
  int upcomingType;
  int videoType;
  int typeId;
  TestTVHome(
      {super.key,
      required this.videoId,
      required this.upcomingType,
      required this.videoType,
      required this.typeId});

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
      widget.videoType == 2 ? "showdetail" : "videodetail",
      widget.videoId,
      widget.upcomingType,
      widget.videoType,
      widget.typeId,
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
