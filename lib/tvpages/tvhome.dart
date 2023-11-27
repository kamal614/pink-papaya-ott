import 'dart:async';
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dtlive/pages/loginsocial.dart';
import 'package:dtlive/provider/generalprovider.dart';
import 'package:dtlive/subscription/subscription.dart';
import 'package:dtlive/tvpages/tvchannels.dart';
import 'package:dtlive/tvpages/tvrentstore.dart';
import 'package:dtlive/provider/searchprovider.dart';
import 'package:dtlive/shimmer/shimmerutils.dart';
import 'package:dtlive/utils/sharedpre.dart';
import 'package:dtlive/utils/strings.dart';
import 'package:dtlive/model/sectionlistmodel.dart';
import 'package:dtlive/model/sectiontypemodel.dart' as type;
import 'package:dtlive/model/sectionlistmodel.dart' as list;
import 'package:dtlive/model/sectionbannermodel.dart' as banner;
import 'package:dtlive/utils/constant.dart';
import 'package:dtlive/utils/dimens.dart';
import 'package:dtlive/tvpages/tvvideosbyid.dart';
import 'package:dtlive/provider/homeprovider.dart';
import 'package:dtlive/provider/sectiondataprovider.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/webwidget/footerweb.dart';
import 'package:dtlive/webwidget/searchweb.dart';
import 'package:dtlive/widget/myimage.dart';
import 'package:dtlive/widget/mytext.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:dtlive/widget/mynetworkimg.dart';
// import 'package:dtlive/widget/mytextgraident.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class TVHome extends StatefulWidget {
  final String? pageName;
  const TVHome({Key? key, required this.pageName}) : super(key: key);

  @override
  State<TVHome> createState() => TVHomeState();
}

class TVHomeState extends State<TVHome> {
  // bool _hovering = false;
  //List<bool> isHovered = List.generate(100, (index) => false); // Initialize with false for all items
  Map<int, bool> isHovered = {};
  late SectionDataProvider sectionDataProvider;
  final FirebaseAuth auth = FirebaseAuth.instance;
  SharedPre sharedPref = SharedPre();
  // final ScrollController _scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  late HomeProvider homeProvider;
  late SearchProvider searchProvider;
  CarouselController carouselController = CarouselController();

  int? videoId, videoType, typeId;
  bool isSearchEnable = false;
  String? currentPage, langCatName, mSearchText;

  _onItemTapped(String page) async {
    debugPrint("_onItemTapped -----------------> $page");
    await homeProvider.setCurrentPage(page);
    if (page != "") {
      await setSelectedTab(-1);
    }
    if (page != "search") {
      isSearchEnable = false;
      mSearchText = "";
      searchController.clear();
      searchProvider.clearProvider();
      await searchProvider.notifyProvider();
    }
    setState(() {
      currentPage = page;
    });
  }

  //int? hoveredIndex;

  // _hovered(bool hovered) {
  //   setState(() {
  //     _hovering = hovered;
  //   });
  // }

  void _setHovered(int videoId, bool value) {
    setState(() {
      isHovered[videoId] = value;
    });
  }

  // void _setHovered(int index, bool value) {
  //   setState(() {
  //     isHovered[index] = value;
  //   });
  // }

  @override
  void initState() {
    currentPage = widget.pageName ?? "";
    sectionDataProvider =
        Provider.of<SectionDataProvider>(context, listen: false);
    searchProvider = Provider.of<SearchProvider>(context, listen: false);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
  }

  _getData() async {
    Utils.getCurrencySymbol();
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);

    Constant.userID = await sharedPref.read("userid");
    debugPrint('userID ==> ${Constant.userID}');
    await homeProvider.setLoading(true);
    await homeProvider.getSectionType();

    if (!homeProvider.loading) {
      if (homeProvider.sectionTypeModel.status == 200 &&
          homeProvider.sectionTypeModel.result != null) {
        if ((homeProvider.sectionTypeModel.result?.length ?? 0) > 0) {
          if ((sectionDataProvider.sectionBannerModel.result?.length ?? 0) ==
                  0 ||
              (sectionDataProvider.sectionListModel.result?.length ?? 0) == 0) {
            getTabData(0, homeProvider.sectionTypeModel.result);
          }
        }
      }
    }

    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
    if (!mounted) return;
    generalProvider.getGeneralsetting(context);
  }

  Future<void> setSelectedTab(int tabPos) async {
    if (!mounted) return;
    await homeProvider.setSelectedTab(tabPos);

    debugPrint("getTabData position ====> $tabPos");
    debugPrint(
        "getTabData lastTabPosition ====> ${sectionDataProvider.lastTabPosition}");
    if (sectionDataProvider.lastTabPosition == tabPos) {
      return;
    } else {
      sectionDataProvider.setTabPosition(tabPos);
    }
  }

  Future<void> getTabData(
      int position, List<type.Result>? sectionTypeList) async {
    await setSelectedTab(position);
    await sectionDataProvider.setLoading(true);
    await sectionDataProvider.getSectionBanner(
        position == 0 ? "0" : (sectionTypeList?[position - 1].id),
        position == 0 ? "1" : "2");
    await sectionDataProvider.getSectionList(
        position == 0 ? "0" : (sectionTypeList?[position - 1].id),
        position == 0 ? "1" : "2");
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

  Widget _clickToRedirect({required String pageName}) {
    switch (pageName) {
      case "channel":
        return const TVChannels();
      case "store":
        return const TVRentStore();
      case "search":
        return SearchWeb(searchText: mSearchText);
      default:
        return tabItem(homeProvider.sectionTypeModel.result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      body: SafeArea(
        child: _tvAppBarWithDetails(),
      ),
    );
  }

  Widget _tvAppBarWithDetails() {
    if (homeProvider.loading) {
      return ShimmerUtils.buildHomeMobileShimmer(context);
    } else {
      if (homeProvider.sectionTypeModel.status == 200) {
        if (homeProvider.sectionTypeModel.result != null ||
            (homeProvider.sectionTypeModel.result?.length ?? 0) > 0) {
          return Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _clickToRedirect(pageName: currentPage ?? ""),
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget _buildAppBar() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: Dimens.homeTabHeight,
      padding: const EdgeInsets.fromLTRB(45, 13, 10, 5),
      color: black.withOpacity(0.75),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /* Menu */
          (MediaQuery.of(context).size.width < 800)
              ? Container(
                  constraints: const BoxConstraints(
                    minWidth: 25,
                  ),
                  padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                  child: Consumer<HomeProvider>(
                    builder: (context, homeProvider, child) {
                      return DropdownButtonHideUnderline(
                        child: DropdownButton2(
                          isDense: true,
                          isExpanded: true,
                          customButton: MyImage(
                            height: 40,
                            imagePath: "ic_menu.png",
                            fit: BoxFit.contain,
                            color: white,
                          ),
                          items: _buildWebDropDownItems(),
                          onChanged: (type.Result? value) async {
                            if (kIsWeb) {
                              _onItemTapped("");
                            }
                            debugPrint(
                                'value id ===============> ${value?.id.toString()}');
                            if (value?.id == 0) {
                              await getTabData(
                                  0, homeProvider.sectionTypeModel.result);
                            } else {
                              for (var i = 0;
                                  i <
                                      (homeProvider.sectionTypeModel.result
                                              ?.length ??
                                          0);
                                  i++) {
                                if (value?.id ==
                                    homeProvider
                                        .sectionTypeModel.result?[i].id) {
                                  await getTabData(i + 1,
                                      homeProvider.sectionTypeModel.result);
                                  return;
                                }
                              }
                            }
                          },
                          dropdownStyleData: DropdownStyleData(
                            width: 180,
                            useSafeArea: true,
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            decoration: Utils.setBackground(lightBlack, 5),
                            //decoration: BoxDecoration(color: Colors.transparent),
                            elevation: 9,
                          ),
                          menuItemStyleData: MenuItemStyleData(
                            overlayColor: MaterialStateProperty.resolveWith(
                              (states) {
                                if (states.contains(MaterialState.focused)) {
                                  return white.withOpacity(0.5);
                                }
                                return transparentColor;
                              },
                            ),
                          ),
                          buttonStyleData: ButtonStyleData(
                            decoration: Utils.setBGWithBorder(
                                transparentColor, white, 20, 1),
                            overlayColor: MaterialStateProperty.resolveWith(
                              (states) {
                                if (states.contains(MaterialState.focused)) {
                                  return white.withOpacity(0.5);
                                }
                                if (states.contains(MaterialState.hovered)) {
                                  return white.withOpacity(0.5);
                                }
                                return transparentColor;
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              : const SizedBox.shrink(),

          /* App Icon */
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              focusColor: white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              onTap: () async {
                if (Constant.isTV) _onItemTapped("");
                await getTabData(0, homeProvider.sectionTypeModel.result);
              },
              child: Container(
                padding: const EdgeInsets.only(
                    left: 25, right: 20, top: 3, bottom: 20),
                child: MyImage(width: 75, height: 80, imagePath: "appicon.png"),
              ),
            ),
          ),

          /* Types */
          (MediaQuery.of(context).size.width >= 800)
              ? Expanded(child: tabTitle(homeProvider.sectionTypeModel.result))
              : const Expanded(child: SizedBox.shrink()),
          const SizedBox(width: 10),

          /* Feature buttons */
          /* Search */
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              focusColor: white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(5),
              onTap: () {
                debugPrint("isSearchEnable ====> $isSearchEnable");
                if (!isSearchEnable) {
                  FocusScope.of(context).requestFocus();
                } else {
                  FocusScope.of(context).unfocus();
                }
                setState(() {
                  isSearchEnable = !isSearchEnable;
                });
              },
              child: Container(
                height: 25,
                constraints: const BoxConstraints(minWidth: 80, maxWidth: 150),
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                decoration: BoxDecoration(
                  color: transparentColor,
                  border: Border.all(
                    color: colorPrimary,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        alignment: Alignment.center,
                        child: TextField(
                          enabled: isSearchEnable,
                          onChanged: (value) async {
                            debugPrint("value ====> $value");
                            if (value.isNotEmpty) {
                              mSearchText = value;
                              debugPrint("mSearchText ====> $mSearchText");
                              _onItemTapped("search");
                              await searchProvider.setLoading(true);
                              await searchProvider.getSearchVideo(mSearchText);
                            }
                          },
                          textInputAction: TextInputAction.done,
                          obscureText: false,
                          controller: searchController,
                          keyboardType: TextInputType.text,
                          maxLines: 1,
                          style: const TextStyle(
                            color: white,
                            fontSize: 14,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.w600,
                          ),
                          onSubmitted: (value) {
                            if (isSearchEnable) {
                              isSearchEnable = false;
                              FocusScope.of(context).unfocus();
                            }
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            filled: true,
                            isCollapsed: true,
                            fillColor: transparentColor,
                            hintStyle: TextStyle(
                              color: otherColor,
                              fontSize: 13,
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.w500,
                            ),
                            hintText: searchHint2,
                          ),
                        ),
                      ),
                    ),
                    Consumer<SearchProvider>(
                      builder: (context, searchProvider, child) {
                        if (searchController.text.toString().isNotEmpty) {
                          return Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              focusColor: white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(5),
                              onTap: () async {
                                debugPrint("Click on Clear!");
                                _onItemTapped("");
                                searchController.clear();
                                if (isSearchEnable) {
                                  isSearchEnable = false;
                                  FocusScope.of(context).unfocus();
                                }
                                await searchProvider.clearProvider();
                                await searchProvider.notifyProvider();
                                setState(() {});
                              },
                              child: Container(
                                constraints: const BoxConstraints(
                                  minWidth: 25,
                                  maxWidth: 25,
                                ),
                                padding: const EdgeInsets.all(5),
                                alignment: Alignment.center,
                                child: MyImage(
                                  height: 23,
                                  color: white,
                                  fit: BoxFit.contain,
                                  imagePath: "ic_close.png",
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              focusColor: white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(5),
                              onTap: () async {
                                debugPrint("Click on Search!");
                                if (searchController.text
                                    .toString()
                                    .isNotEmpty) {
                                  if (isSearchEnable) {
                                    isSearchEnable = false;
                                    FocusScope.of(context).unfocus();
                                  }
                                  mSearchText =
                                      searchController.text.toString();
                                  debugPrint("mSearchText ====> $mSearchText");
                                  _onItemTapped("search");
                                  await searchProvider.setLoading(true);
                                  await searchProvider
                                      .getSearchVideo(mSearchText);
                                  setState(() {});
                                }
                              },
                              child: Container(
                                constraints: const BoxConstraints(
                                  minWidth: 25,
                                  maxWidth: 25,
                                ),
                                padding: const EdgeInsets.all(5),
                                alignment: Alignment.center,
                                child: MyImage(
                                  height: 23,
                                  color: white,
                                  fit: BoxFit.contain,
                                  imagePath: "ic_find.png",
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          /* Channels */
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              focusColor: white.withOpacity(0.5),
              onTap: () async {
                _onItemTapped("channel");
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Consumer<HomeProvider>(
                  builder: (context, homeProvider, child) {
                    // return MyText(
                    //   color: homeProvider.currentPage == "channel"
                    //       ? colorPrimary
                    //       : white,
                    //   multilanguage: false,
                    //   text: bottomView3,
                    //   maxline: 1,
                    //   overflow: TextOverflow.ellipsis,
                    //   fontsizeNormal: 12,
                    //   fontweight: FontWeight.w400,
                    //   fontsizeWeb: 12,
                    //   textalign: TextAlign.center,
                    //   fontstyle: FontStyle.normal,
                    // );
                    return Icon(
                      Icons.tv,
                      size: 20,
                      color: (homeProvider.currentPage == "login")
                          ? colorPrimary
                          : white,
                    );
                  },
                ),
              ),
            ),
          ),

          /* Rent */
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              focusColor: white.withOpacity(0.5),
              onTap: () async {
                _onItemTapped("store");
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Consumer<HomeProvider>(
                  builder: (context, homeProvider, child) {
                    // return MyText(
                    //   color: homeProvider.currentPage == "store"
                    //       ? colorPrimary
                    //       : white,
                    //   multilanguage: false,
                    //   text: bottomView4,
                    //   maxline: 1,
                    //   overflow: TextOverflow.ellipsis,
                    //   fontsizeNormal: 12,
                    //   fontweight: FontWeight.w400,
                    //   fontsizeWeb: 12,
                    //   textalign: TextAlign.center,
                    //   fontstyle: FontStyle.normal,
                    // );

                    return Icon(
                      Icons.store_sharp,
                      size: 20,
                      color: (homeProvider.currentPage == "login")
                          ? colorPrimary
                          : white,
                    );
                  },
                ),
              ),
            ),
          ),

          /* Login / MyProfile */
          Consumer<HomeProvider>(
            builder: (context, homeProvider, child) {
              if (Constant.userID != null) {
                return Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    focusColor: white.withOpacity(0.5),
                    onTap: () {
                      Utils.buildWebAlertDialog(context, "profile", "");
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.person,
                        size: 20,
                        color: (homeProvider.currentPage == "login")
                            ? colorPrimary
                            : white,
                      ),
                    ),
                  ),
                );
              } else {
                return Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    focusColor: white.withOpacity(0.5),
                    onTap: () async {
                      Utils.buildWebAlertDialog(context, "login", "")
                          .then((value) => _getData());
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      // child: MyText(
                      //   color: (homeProvider.currentPage == "login")
                      //       ? colorPrimary
                      //       : white,
                      //   multilanguage: true,
                      //   text: "login",
                      //   fontsizeNormal: 12,
                      //   fontweight: FontWeight.w500,
                      //   fontsizeWeb: 12,
                      //   maxline: 1,
                      //   overflow: TextOverflow.ellipsis,
                      //   textalign: TextAlign.center,
                      //   fontstyle: FontStyle.normal,
                      // ),
                      child: Icon(
                        Icons.person,
                        size: 20,
                        color: (homeProvider.currentPage == "login")
                            ? colorPrimary
                            : white,
                      ),
                    ),
                  ),
                );
              }
            },
          ),

          /* Logout */
          Consumer<HomeProvider>(
            builder: (context, homeProvider, child) {
              if (Constant.userID != null) {
                return Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    focusColor: white.withOpacity(0.5),
                    onTap: () async {
                      if (Constant.userID != null) {
                        _buildLogoutDialog();
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      // child: MyText(
                      //   color: white,
                      //   multilanguage: true,
                      //   text: "sign_out",
                      //   fontsizeNormal: 14,
                      //   fontweight: FontWeight.w600,
                      //   fontsizeWeb: 14,
                      //   maxline: 1,
                      //   overflow: TextOverflow.ellipsis,
                      //   textalign: TextAlign.center,
                      //   fontstyle: FontStyle.normal,
                      // ),
                      child: Icon(
                        Icons.logout_outlined,
                        size: 20,
                        color: (homeProvider.currentPage == "login")
                            ? colorPrimary
                            : white,
                      ),
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget tabTitle(List<type.Result>? sectionTypeList) {
    return ListView.separated(
      itemCount: (sectionTypeList?.length ?? 0) + 1,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      physics: const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(13, 3, 13, 3),
      separatorBuilder: (context, index) => const SizedBox(width: 5),
      itemBuilder: (BuildContext context, int index) {
        return Consumer<HomeProvider>(
          builder: (context, homeProvider, child) {
            return Material(
              type: MaterialType.transparency,
              child: InkWell(
                autofocus: true,
                // focusColor: kIsWeb
                //     ? homeProvider.selectedIndex == index
                //         ? colorPrimary
                //         : transparentColor
                //     : (homeProvider.selectedIndex == index
                //         ? colorPrimary
                //         : white.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(25),
                onTap: () async {
                  debugPrint("index ===========> $index");
                  _onItemTapped("");
                  await getTabData(index, homeProvider.sectionTypeModel.result);
                },
                child: Container(
                  padding: const EdgeInsets.all(2.0),
                  child: Column(
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxHeight: 32),
                        // decoration: Utils.setBackground(
                        //   homeProvider.selectedIndex == index
                        //       ? white
                        //       : transparentColor,
                        //   20,
                        // ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.fromLTRB(13, 0, 13, 0),
                        child: MyText(
                          color: homeProvider.selectedIndex == index
                              ? primaryLight
                              : white,
                          multilanguage: false,
                          text: index == 0
                              ? "Home"
                              : index > 0
                                  ? (sectionTypeList?[index - 1]
                                          .name
                                          .toString() ??
                                      "")
                                  : "",
                          fontsizeNormal: 11,
                          fontweight: FontWeight.w600,
                          fontsizeWeb: 14,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<DropdownMenuItem<type.Result>>? _buildWebDropDownItems() {
    List<type.Result>? typeDropDownList = [];
    for (var i = 0;
        i < (homeProvider.sectionTypeModel.result?.length ?? 0) + 1;
        i++) {
      if (i == 0) {
        type.Result typeHomeResult = type.Result();
        typeHomeResult.id = 0;
        typeHomeResult.name = "Home";
        typeDropDownList.insert(i, typeHomeResult);
      } else {
        typeDropDownList.insert(i,
            (homeProvider.sectionTypeModel.result?[(i - 1)] ?? type.Result()));
      }
    }
    return typeDropDownList
        .map<DropdownMenuItem<type.Result>>((type.Result value) {
      return DropdownMenuItem<type.Result>(
        value: value,
        alignment: Alignment.center,
        child: FittedBox(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 35, minWidth: 100),
            decoration: Utils.setBackground(
              homeProvider.selectedIndex != -1
                  ? ((typeDropDownList[homeProvider.selectedIndex].id ?? 0) ==
                          (value.id ?? 0)
                      ? white
                      : transparentColor)
                  : transparentColor,
              20,
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: MyText(
              color: homeProvider.selectedIndex != -1
                  ? ((typeDropDownList[homeProvider.selectedIndex].id ?? 0) ==
                          (value.id ?? 0)
                      ? black
                      : white)
                  : white,
              multilanguage: false,
              text: (value.name.toString()),
              fontsizeNormal: 14,
              fontweight: FontWeight.w600,
              fontsizeWeb: 15,
              maxline: 1,
              overflow: TextOverflow.ellipsis,
              textalign: TextAlign.center,
              fontstyle: FontStyle.normal,
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget tabItem(List<type.Result>? sectionTypeList) {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: const BoxConstraints.expand(),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            /* Banner */
            // SizedBox(height: 10,) ,
            Consumer<SectionDataProvider>(
              builder: (context, sectionDataProvider, child) {
                if (sectionDataProvider.loadingBanner) {
                  if ((kIsWeb || Constant.isTV) &&
                      MediaQuery.of(context).size.width > 720) {
                    return ShimmerUtils.bannerWeb(context);
                  } else {
                    return ShimmerUtils.bannerMobile(context);
                  }
                } else {
                  if (sectionDataProvider.sectionBannerModel.status == 200 &&
                      sectionDataProvider.sectionBannerModel.result != null) {
                    if ((kIsWeb || Constant.isTV) &&
                        MediaQuery.of(context).size.width > 720) {
                      return _tvHomeBanner(
                          sectionDataProvider.sectionBannerModel.result);
                    } else {
                      return _mobileHomeBanner(
                          sectionDataProvider.sectionBannerModel.result);
                    }
                  } else {
                    return const SizedBox.shrink();
                  }
                }
              },
            ),

            /* Continue Watching & Remaining Sections */
            Consumer<SectionDataProvider>(
              builder: (context, sectionDataProvider, child) {
                if (sectionDataProvider.loadingSection) {
                  return sectionShimmer();
                } else {
                  if (sectionDataProvider.sectionListModel.status == 200) {
                    return Column(
                      children: [
                        /* Continue Watching */
                        (sectionDataProvider
                                    .sectionListModel.continueWatching !=
                                null)
                            ? continueWatchingLayout(sectionDataProvider
                                .sectionListModel.continueWatching)
                            : const SizedBox.shrink(),

                        /* Remaining Sections */
                        (sectionDataProvider.sectionListModel.result != null)
                            ? setSectionByType(
                                sectionDataProvider.sectionListModel.result)
                            : const SizedBox.shrink(),
                      ],
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }
              },
            ),
            const SizedBox(height: 20),

            /* Web Footer */
            kIsWeb ? const FooterWeb() : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  /* Section Shimmer */
  Widget sectionShimmer() {
    return Column(
      children: [
        /* Continue Watching */
        if (Constant.userID != null && homeProvider.selectedIndex == 0)
          ShimmerUtils.continueWatching(context),

        /* Remaining Sections */
        ListView.builder(
          itemCount: 10, // itemCount must be greater than 5
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            if (index == 1) {
              return ShimmerUtils.setHomeSections(context, "potrait");
            } else if (index == 2) {
              return ShimmerUtils.setHomeSections(context, "square");
            } else if (index == 3) {
              return ShimmerUtils.setHomeSections(context, "langGen");
            } else {
              return ShimmerUtils.setHomeSections(context, "landscape");
            }
          },
        ),
      ],
    );
  }

  // Widget _tvHomeBanner(List<banner.Result>? sectionBannerList) {
  //   if ((sectionBannerList?.length ?? 0) > 0) {
  //     return SizedBox(
  //       width: MediaQuery.of(context).size.width,
  //       height: Dimens.homeWebBanner,
  //       child: CarouselSlider.builder(
  //         itemCount: (sectionBannerList?.length ?? 0),
  //         carouselController: carouselController,
  //         options: CarouselOptions(
  //           initialPage: 0,
  //           height: Dimens.homeWebBanner,
  //           enlargeCenterPage: false,
  //           autoPlay: true,
  //           autoPlayCurve: Curves.easeInOutQuart,
  //           enableInfiniteScroll: true,
  //           autoPlayInterval: Duration(milliseconds: Constant.bannerDuration),
  //           autoPlayAnimationDuration:
  //               Duration(milliseconds: Constant.animationDuration),
  //           viewportFraction: 1,
  //           onPageChanged: (val, _) async {
  //             await sectionDataProvider.setCurrentBanner(val);
  //           },
  //         ),
  //         itemBuilder: (BuildContext context, int index, int pageViewIndex) {
  //           return InkWell(
  //             focusColor: white,
  //             borderRadius: BorderRadius.circular(4),
  //             onTap: () {
  //               debugPrint("Clicked on index ==> $index");
  //               openDetailPage(
  //                 (sectionBannerList?[index].videoType ?? 0) == 2
  //                     ? "showdetail"
  //                     : "videodetail",
  //                 sectionBannerList?[index].id ?? 0,
  //                 sectionBannerList?[index].upcomingType ?? 0,
  //                 sectionBannerList?[index].videoType ?? 0,
  //                 sectionBannerList?[index].typeId ?? 0,
  //               );
  //             },
  //             child: Container(
  //               padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
  //               child: ClipRRect(
  //                 borderRadius: BorderRadius.circular(4),
  //                 clipBehavior: Clip.antiAliasWithSaveLayer,
  //                 child: Stack(
  //                   alignment: AlignmentDirectional.centerEnd,
  //                   children: [
  //                     SizedBox(
  //                       width: MediaQuery.of(context).size.width *
  //                           (Dimens.webBannerImgPr),
  //                       height: Dimens.homeWebBanner,
  //                       child: MyNetworkImage(
  //                         imageUrl: sectionBannerList?[index].landscape ?? "",
  //                         fit: BoxFit.fill,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           );
  //         },
  //       ),
  //     );
  //   } else {
  //     return const SizedBox.shrink();
  //   }
  // }
  Widget _tvHomeBanner(List<banner.Result>? sectionBannerList) {
    if ((sectionBannerList?.length ?? 0) > 0) {
      return Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: Dimens.homeWebBanner,
            child: Stack(
              children: [
                CarouselSlider.builder(
                  itemCount: (sectionBannerList?.length ?? 0),
                  carouselController: carouselController,
                  options: CarouselOptions(
                    initialPage: 0,
                    height: Dimens.homeWebBanner,
                    enlargeCenterPage: false,
                    autoPlay: true,
                    autoPlayCurve: Curves.easeInOutQuart,
                    enableInfiniteScroll: true,
                    autoPlayInterval:
                        Duration(milliseconds: Constant.bannerDuration),
                    autoPlayAnimationDuration:
                        Duration(milliseconds: Constant.animationDuration),
                    viewportFraction: 1,
                    onPageChanged: (val, _) async {
                      await sectionDataProvider.setCurrentBanner(val);
                    },
                  ),
                  itemBuilder:
                      (BuildContext context, int index, int pageViewIndex) {
                    return InkWell(
                      focusColor: white,
                      borderRadius: BorderRadius.circular(4),
                      onTap: () {
                        print(
                            "ANIL KHANDELWAL IMAGE FULL WIDTH --${sectionBannerList?[index].full_width}");
                        debugPrint("Clicked on index ==> $index");
                        openDetailPage(
                          (sectionBannerList?[index].videoType ?? 0) == 2
                              ? "showdetail"
                              : "videodetail",
                          sectionBannerList?[index].id ?? 0,
                          sectionBannerList?[index].upcomingType ?? 0,
                          sectionBannerList?[index].videoType ?? 0,
                          sectionBannerList?[index].typeId ?? 0,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Stack(
                            alignment: AlignmentDirectional.centerEnd,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    (Dimens.webBannerImgPr),
                                height: Dimens.homeWebBanner,
                                child: MyNetworkImage(
                                  imageUrl:
                                      sectionBannerList?[index].full_width ??
                                          "",
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Left arrow button
                Positioned(
                  left: 16,
                  top: Dimens.homeWebBanner / 2 - 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      carouselController.previousPage();
                    },
                  ),
                ),

                // Right arrow button
                Positioned(
                  right: 16,
                  top: Dimens.homeWebBanner / 2 - 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      carouselController.nextPage();
                    },
                  ),
                ),

                // Dot indicators
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Consumer<SectionDataProvider>(
                    builder: (context, sectionDataProvider, child) {
                      return Center(
                        child: AnimatedSmoothIndicator(
                          count: (sectionBannerList?.length ?? 0),
                          activeIndex: sectionDataProvider.cBannerIndex ?? 0,
                          effect: const ScrollingDotsEffect(
                            spacing: 8,
                            radius: 4,
                            activeDotColor: colorPrimary,
                            dotColor: white,
                            dotHeight: 8,
                            dotWidth: 8,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 18,
          )
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  // Widget _tvHomeBanner(List<banner.Result>? sectionBannerList) {
  //   if ((sectionBannerList?.length ?? 0) > 0) {
  //     return Column(
  //       children: [
  //         SizedBox(
  //           width: MediaQuery.of(context).size.width,
  //           height: Dimens.homeWebBanner,
  //           child: Stack(
  //             children: [
  //               CarouselSlider.builder(
  //                 itemCount: (sectionBannerList?.length ?? 0),
  //                 carouselController: carouselController,
  //                 options: CarouselOptions(
  //                   initialPage: 0,
  //                   height: Dimens.homeWebBanner,
  //                   enlargeCenterPage: false,
  //                   autoPlay: true,
  //                   autoPlayCurve: Curves.easeInOutQuart,
  //                   enableInfiniteScroll: true,
  //                   autoPlayInterval:
  //                       Duration(milliseconds: Constant.bannerDuration),
  //                   autoPlayAnimationDuration:
  //                       Duration(milliseconds: Constant.animationDuration),
  //                   viewportFraction: 1,
  //                   onPageChanged: (val, _) async {
  //                     await sectionDataProvider.setCurrentBanner(val);
  //                   },
  //                 ),
  //                 itemBuilder:
  //                     (BuildContext context, int index, int pageViewIndex) {
  //                   return InkWell(
  //                     focusColor: white,
  //                     borderRadius: BorderRadius.circular(4),
  //                     onTap: () {
  //                       print("ANIL KHANDELWAL IMAGE FULL WIDTH --${sectionBannerList?[index].full_width}");
  //                       debugPrint("Clicked on index ==> $index");
  //                       openDetailPage(
  //                         (sectionBannerList?[index].videoType ?? 0) == 2
  //                             ? "showdetail"
  //                             : "videodetail",
  //                         sectionBannerList?[index].id ?? 0,
  //                         sectionBannerList?[index].upcomingType ?? 0,
  //                         sectionBannerList?[index].videoType ?? 0,
  //                         sectionBannerList?[index].typeId ?? 0,
  //                       );
  //                     },
  //                     child: Container(
  //                       padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
  //                       child: ClipRRect(
  //                         borderRadius: BorderRadius.circular(4),
  //                         clipBehavior: Clip.antiAliasWithSaveLayer,
  //                         child: Stack(
  //                           alignment: AlignmentDirectional.centerEnd,
  //                           children: [
  //                             SizedBox(
  //                               width: MediaQuery.of(context).size.width *
  //                                   (Dimens.webBannerImgPr),
  //                               height: Dimens.homeWebBanner,
  //                               child: MyNetworkImage(
  //                                 imageUrl:
  //                                     sectionBannerList?[index].full_width?? "",
  //                                 fit: BoxFit.fill,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   );
  //                 },
  //               ),

  //               // Dot indicators
  //               Positioned(
  //                 bottom: 10,
  //                 left: 0,
  //                 right: 0,
  //                 child: Consumer<SectionDataProvider>(
  //                   builder: (context, sectionDataProvider, child) {
  //                     return Center(
  //                       child: AnimatedSmoothIndicator(
  //                         count: (sectionBannerList?.length ?? 0),
  //                         activeIndex: sectionDataProvider.cBannerIndex ?? 0,
  //                         effect: const ScrollingDotsEffect(
  //                           spacing: 8,
  //                           radius: 4,
  //                           activeDotColor: colorPrimary,
  //                           dotColor: white,
  //                           dotHeight: 8,
  //                           dotWidth: 8,
  //                         ),
  //                       ),
  //                     );
  //                   },
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     );
  //   } else {
  //     return const SizedBox.shrink();
  //   }
  // }

  Widget _mobileHomeBanner(List<banner.Result>? sectionBannerList) {
    if ((sectionBannerList?.length ?? 0) > 0) {
      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: Dimens.homeBanner,
            child: CarouselSlider.builder(
              itemCount: (sectionBannerList?.length ?? 0),
              carouselController: carouselController,
              options: CarouselOptions(
                initialPage: 0,
                height: Dimens.homeBanner,
                enlargeCenterPage: false,
                autoPlay: true,
                autoPlayCurve: Curves.linear,
                enableInfiniteScroll: true,
                autoPlayInterval:
                    Duration(milliseconds: Constant.bannerDuration),
                autoPlayAnimationDuration:
                    Duration(milliseconds: Constant.animationDuration),
                viewportFraction: 1.0,
                onPageChanged: (val, _) async {
                  await sectionDataProvider.setCurrentBanner(val);
                },
              ),
              itemBuilder:
                  (BuildContext context, int index, int pageViewIndex) {
                return InkWell(
                  focusColor: white,
                  borderRadius: BorderRadius.circular(0),
                  onTap: () {
                    debugPrint("Clicked on index ==> $index");
                    openDetailPage(
                      (sectionBannerList?[index].videoType ?? 0) == 2
                          ? "showdetail"
                          : "videodetail",
                      sectionBannerList?[index].id ?? 0,
                      sectionBannerList?[index].upcomingType ?? 0,
                      sectionBannerList?[index].videoType ?? 0,
                      sectionBannerList?[index].typeId ?? 0,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Stack(
                      alignment: AlignmentDirectional.bottomCenter,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: Dimens.homeBanner,
                          child: MyNetworkImage(
                            imageUrl: sectionBannerList?[index].landscape ?? "",
                            fit: BoxFit.fill,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(0),
                          width: MediaQuery.of(context).size.width,
                          height: Dimens.homeBanner,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.center,
                              end: Alignment.bottomCenter,
                              colors: [
                                transparentColor,
                                transparentColor,
                                appBgColor,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 0,
            child: Consumer<SectionDataProvider>(
              builder: (context, sectionDataProvider, child) {
                return AnimatedSmoothIndicator(
                  count: (sectionBannerList?.length ?? 0),
                  activeIndex: sectionDataProvider.cBannerIndex ?? 0,
                  effect: const ScrollingDotsEffect(
                    spacing: 8,
                    radius: 4,
                    activeDotColor: colorPrimary,
                    dotColor: white,
                    dotHeight: 8,
                    dotWidth: 8,
                  ),
                );
              },
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget continueWatchingLayout(List<ContinueWatching>? continueWatchingList) {
    if ((continueWatchingList?.length ?? 0) > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: MyText(
              color: white,
              text: "continuewatching",
              multilanguage: true,
              textalign: TextAlign.center,
              fontsizeNormal: 14,
              fontsizeWeb: 16,
              fontweight: FontWeight.w600,
              maxline: 1,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: Dimens.heightContiLand,
            child: ListView.separated(
              itemCount: (continueWatchingList?.length ?? 0),
              shrinkWrap: true,
              padding: const EdgeInsets.only(left: 20, right: 20),
              scrollDirection: Axis.horizontal,
              physics: const PageScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              separatorBuilder: (context, index) => const SizedBox(
                width: 10,
              ),
              itemBuilder: (BuildContext context, int index) {
                return Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    focusColor: white,
                    borderRadius: BorderRadius.circular(4),
                    onTap: () async {
                      openPlayer("ContinueWatch", index, continueWatchingList);
                    },
                    child: Stack(
                      alignment: AlignmentDirectional.bottomStart,
                      children: [
                        Container(
                          width: Dimens.widthContiLand,
                          height: Dimens.heightContiLand,
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: MyNetworkImage(
                              imageUrl:
                                  continueWatchingList?[index].landscape ?? "",
                              fit: BoxFit.cover,
                              imgHeight: MediaQuery.of(context).size.height,
                              imgWidth: MediaQuery.of(context).size.width,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, bottom: 8),
                              child: MyImage(
                                width: 30,
                                height: 30,
                                imagePath: "play.png",
                              ),
                            ),
                            Container(
                              width: Dimens.widthContiLand,
                              constraints: const BoxConstraints(minWidth: 0),
                              padding: const EdgeInsets.all(3),
                              child: LinearPercentIndicator(
                                padding: const EdgeInsets.all(0),
                                barRadius: const Radius.circular(2),
                                lineHeight: 4,
                                percent: Utils.getPercentage(
                                    continueWatchingList?[index]
                                            .videoDuration ??
                                        0,
                                    continueWatchingList?[index].stopTime ?? 0),
                                backgroundColor: secProgressColor,
                                progressColor: colorPrimary,
                              ),
                            ),
                            (continueWatchingList?[index].releaseTag != null &&
                                    (continueWatchingList?[index].releaseTag ??
                                            "")
                                        .isNotEmpty)
                                ? Container(
                                    decoration: const BoxDecoration(
                                      color: black,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(4),
                                        bottomRight: Radius.circular(4),
                                      ),
                                      shape: BoxShape.rectangle,
                                    ),
                                    alignment: Alignment.center,
                                    width: Dimens.widthContiLand,
                                    height: 15,
                                    child: MyText(
                                      color: white,
                                      multilanguage: false,
                                      text: continueWatchingList?[index]
                                              .releaseTag ??
                                          "",
                                      textalign: TextAlign.center,
                                      fontsizeNormal: 6,
                                      fontweight: FontWeight.w700,
                                      fontsizeWeb: 10,
                                      maxline: 1,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget setSectionByType(List<list.Result>? sectionList) {
    return ListView.builder(
      itemCount: sectionList?.length ?? 0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        if (sectionList?[index].data != null &&
            (sectionList?[index].data?.length ?? 0) > 0) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //  const SizedBox(height: 18),
              Row(
                children: [
                  SizedBox(
                    width: 60,
                  ),
                  // Container(
                  //   height: 20,
                  //   width: 3,
                  //   color: colorPrimary,
                  // ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                    child: MyText(
                      color: white,
                      text: sectionList?[index].title.toString() ?? "",
                      textalign: TextAlign.center,
                      fontsizeNormal: 14,
                      fontweight: FontWeight.w600,
                      fontsizeWeb: 16,
                      multilanguage: false,
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: getRemainingDataHeight(
                  sectionList?[index].videoType.toString() ?? "",
                  sectionList?[index].screenLayout ?? "",
                ),
                child: setSectionData(sectionList: sectionList, index: index),
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget setSectionData(
      {required List<list.Result>? sectionList, required int index}) {
    /* video_type =>  1-video,  2-show,  3-language,  4-category */
    /* screen_layout =>  landscape, potrait, square */
    if ((sectionList?[index].videoType ?? 0) == 1) {
      if ((sectionList?[index].screenLayout ?? "") == "landscape") {
        return landscape(
            sectionList?[index].upcomingType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "potrait") {
        return portrait(
            sectionList?[index].upcomingType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "square") {
        return square(
            sectionList?[index].upcomingType, sectionList?[index].data);
      } else {
        return landscape(
            sectionList?[index].upcomingType, sectionList?[index].data);
      }
    } else if ((sectionList?[index].videoType ?? 0) == 2) {
      if ((sectionList?[index].screenLayout ?? "") == "landscape") {
        return landscape(
            sectionList?[index].upcomingType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "potrait") {
        return portrait(
            sectionList?[index].upcomingType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "square") {
        return square(
            sectionList?[index].upcomingType, sectionList?[index].data);
      } else {
        return landscape(
            sectionList?[index].upcomingType, sectionList?[index].data);
      }
    } else if ((sectionList?[index].videoType ?? 0) == 3) {
      return languageLayout(
          sectionList?[index].typeId ?? 0, sectionList?[index].data);
    } else if ((sectionList?[index].videoType ?? 0) == 4) {
      return genresLayout(
          sectionList?[index].typeId ?? 0, sectionList?[index].data);
    } else {
      if ((sectionList?[index].screenLayout ?? "") == "landscape") {
        return landscape(
            sectionList?[index].upcomingType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "potrait") {
        return portrait(
            sectionList?[index].upcomingType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "square") {
        return square(
            sectionList?[index].upcomingType, sectionList?[index].data);
      } else {
        return landscape(
            sectionList?[index].upcomingType, sectionList?[index].data);
      }
    }
  }

  double getRemainingDataHeight(String? videoType, String? layoutType) {
    if (videoType == "1" || videoType == "2") {
      if (layoutType == "landscape") {
        return Dimens.heightLand;
      } else if (layoutType == "potrait") {
        return Dimens.heightPort;
      } else if (layoutType == "square") {
        return Dimens.heightSquare;
      } else {
        return Dimens.heightLand;
      }
    } else if (videoType == "3" || videoType == "4") {
      return Dimens.heightLangGen;
    } else {
      if (layoutType == "landscape") {
        return Dimens.heightLand;
      } else if (layoutType == "potrait") {
        return Dimens.heightPort;
      } else if (layoutType == "square") {
        return Dimens.heightSquare;
      } else {
        return Dimens.heightLand;
      }
    }
  }

  Widget landscape(int? upcomingType, List<Datum>? sectionDataList) {
    ScrollController _scrollController = ScrollController();
    void scrollBy(int elements) {
      _scrollController.animateTo(
        _scrollController.position.pixels +
            (elements * (Dimens.widthLand + 15)),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightLand,
      child: Stack(
        children: [
          ListView.separated(
            controller: _scrollController,
            itemCount: sectionDataList?.length ?? 0,
            shrinkWrap: true,
            physics: const PageScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.only(left: 70, right: 15),
            scrollDirection: Axis.horizontal,
            separatorBuilder: (context, index) => const SizedBox(width: 15),
            itemBuilder: (BuildContext context, int index) {
              final videoId = sectionDataList?[index].id ?? 0;
              return InkWell(
                focusColor: white,
                borderRadius: BorderRadius.circular(6),
                onTap: () {
                  debugPrint("Clicked on index ==> $index");
                  openDetailPage(
                    (sectionDataList?[index].videoType ?? 0) == 2
                        ? "showdetail"
                        : "videodetail",
                    videoId,
                    upcomingType ?? 0,
                    sectionDataList?[index].videoType ?? 0,
                    sectionDataList?[index].typeId ?? 0,
                  );
                },
                child: MouseRegion(
                  onHover: (_) => _setHovered(videoId, true),
                  onExit: (_) => _setHovered(videoId, false),
                  child: Column(
                    children: [
                      Container(
                        width: Dimens.widthLand,
                        height: Dimens.heightLand / 1.4,
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Transform.scale(
                            scale: (isHovered[videoId] ?? false) ? 1.1 : 1.0,
                            child: MyNetworkImage(
                              imageUrl: sectionDataList?[index]
                                      .landscape
                                      .toString() ??
                                  "",
                              fit: BoxFit.cover,
                              imgHeight: MediaQuery.of(context).size.height,
                              imgWidth: MediaQuery.of(context).size.width,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      SizedBox(
                          height: 50,
                          width: Dimens.widthLand,
                          child: Text(
                            sectionDataList?[index].name.toString() ?? "",
                            style: TextStyle(
                              color: (isHovered[videoId] ?? false)
                                  ? colorPrimary
                                  : Colors.white,
                              fontSize: (isHovered[videoId] ?? false) ? 15 : 15,
                              height: 1.5,
                            ),
                          )),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            right: 16,
            top: 70,
            child: IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                ),
                onPressed: () {
                  scrollBy(5);
                }),
          ),
          Positioned(
            left: 16,
            top: 70,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onPressed: () {
                scrollBy(-5);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget portrait(int? upcomingType, List<Datum>? sectionDataList) {
    ScrollController _scrollController = ScrollController();
    void scrollBy(int elements) {
      _scrollController.animateTo(
        _scrollController.position.pixels +
            (elements * (Dimens.widthLand + 15)),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightPort,
      child: Stack(
        children: [
          ListView.separated(
            controller: _scrollController,
            itemCount: sectionDataList?.length ?? 0,
            shrinkWrap: true,
            padding: const EdgeInsets.only(left: 20, right: 20),
            scrollDirection: Axis.horizontal,
            physics: const PageScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            separatorBuilder: (context, index) => const SizedBox(width: 5),
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                focusColor: white,
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  debugPrint("Clicked on index ==> $index");
                  openDetailPage(
                    (sectionDataList?[index].videoType ?? 0) == 2
                        ? "showdetail"
                        : "videodetail",
                    sectionDataList?[index].id ?? 0,
                    upcomingType ?? 0,
                    sectionDataList?[index].videoType ?? 0,
                    sectionDataList?[index].typeId ?? 0,
                  );
                },
                child: Container(
                  width: Dimens.widthPort,
                  height: Dimens.heightPort,
                  padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: MyNetworkImage(
                      imageUrl:
                          sectionDataList?[index].thumbnail.toString() ?? "",
                      fit: BoxFit.cover,
                      imgHeight: MediaQuery.of(context).size.height,
                      imgWidth: MediaQuery.of(context).size.width,
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            right: 16,
            top: 70,
            child: IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                ),
                onPressed: () {
                  scrollBy(5);
                }),
          ),
          Positioned(
            left: 16,
            top: 70,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onPressed: () {
                scrollBy(-5);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget square(int? upcomingType, List<Datum>? sectionDataList) {
    ScrollController _scrollController = ScrollController();
    void scrollBy(int elements) {
      _scrollController.animateTo(
        _scrollController.position.pixels +
            (elements * (Dimens.widthLand + 15)),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightSquare,
      child: Stack(
        children: [
          ListView.separated(
            controller: _scrollController,
            itemCount: sectionDataList?.length ?? 0,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            physics: const PageScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.only(left: 70, right: 20),
            separatorBuilder: (context, index) => const SizedBox(width: 15),
            itemBuilder: (BuildContext context, int index) {
              final videoId = sectionDataList?[index].id ?? 0;
              return InkWell(
                focusColor: Colors.white,
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  debugPrint("Clicked on index ==> $index");
                  openDetailPage(
                    (sectionDataList?[index].videoType ?? 0) == 2
                        ? "showdetail"
                        : "videodetail",
                    videoId,
                    upcomingType ?? 0,
                    sectionDataList?[index].videoType ?? 0,
                    sectionDataList?[index].typeId ?? 0,
                  );
                },
                child: MouseRegion(
                  onHover: (_) => _setHovered(videoId, true), // Set hover state
                  onExit: (_) =>
                      _setHovered(videoId, false), // Clear hover state
                  child: Column(
                    children: [
                      Container(
                        width: Dimens.widthSquare,
                        height: Dimens.heightSquare / 1.4,
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Transform.scale(
                            scale: (isHovered[videoId] ?? false) ? 1.1 : 1.0,
                            child: MyNetworkImage(
                              imageUrl: sectionDataList?[index]
                                      .thumbnail
                                      .toString() ??
                                  "",
                              fit: BoxFit.cover,
                              imgHeight: MediaQuery.of(context).size.height,
                              imgWidth: MediaQuery.of(context).size.width,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 2),
                        margin: EdgeInsets.only(bottom: 5),
                        width: Dimens.widthSquare,
                        child: Text(
                          sectionDataList?[index].description.toString() ?? "",
                          maxLines: 3,
                          style: TextStyle(
                            color: (isHovered[videoId] ?? false)
                                ? colorPrimary
                                : Colors.white,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            right: 16,
            top: 70,
            child: IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                ),
                onPressed: () {
                  scrollBy(5);
                }),
          ),
          Positioned(
            left: 16,
            top: 70,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onPressed: () {
                scrollBy(-5);
              },
            ),
          )
        ],
      ),
    );
  }

//   Widget square(int? upcomingType, List<Datum>? sectionDataList) {
//     return SizedBox(
//       width: MediaQuery.of(context).size.width,
//       height: Dimens.heightSquare,
//       child: ListView.separated(
//         itemCount: sectionDataList?.length ?? 0,
//         shrinkWrap: true,
//         scrollDirection: Axis.horizontal,
//         physics:
//             const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
//         padding: const EdgeInsets.only(left: 20, right: 20),
//         separatorBuilder: (context, index) => const SizedBox(width: 15),
//         itemBuilder: (BuildContext context, int index) {
//           return InkWell(
//             focusColor: white,
//             borderRadius: BorderRadius.circular(4),
//             onTap: () {
//               debugPrint("Clicked on index ==> $index");
//               // openDetailPage(
//               //   (sectionDataList?[index].videoType ?? 0) == 2
//               //       ? "showdetail"
//               //       : "videodetail",

//               //   sectionDataList?[index].id ?? 0,
//               //   upcomingType ?? 0,
//               //   sectionDataList?[index].videoType ?? 0,
//               //   sectionDataList?[index].typeId ?? 0,

//               // );
//               openDetailPage(
//   (sectionDataList?[index].videoType ?? 0) == 2
//       ? "showdetail"
//       : "videodetail",
//   videoId!,
//   upcomingType ?? 0,
//   sectionDataList?[index].videoType ?? 0,
//   sectionDataList?[index].typeId ?? 0,
// );
//             },
//             child: MouseRegion(
//                 onHover: (_) => _setHovered(videoId!, true), // Set hover state
//               onExit: (_) => _setHovered(videoId!, false),
//               child: Column(
//                 children: [
//                   Container(
//                     width: Dimens.widthSquare,
//                     height: Dimens.heightSquare / 1.4,
//                     alignment: Alignment.center,
//                     padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(4),
//                       clipBehavior: Clip.antiAliasWithSaveLayer,
//                       child: MyNetworkImage(
//                         imageUrl:
//                             sectionDataList?[index].thumbnail.toString() ?? "",
//                         fit: BoxFit.cover,
//                         imgHeight: MediaQuery.of(context).size.height,
//                         imgWidth: MediaQuery.of(context).size.width,
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 12,
//                   ),
//                   Container(
//                       padding: EdgeInsets.only(left: 2),
//                       margin: EdgeInsets.only(bottom: 5),
//                       // height: 100,
//                       width: Dimens.widthSquare,
//                       child: Text(
//                         sectionDataList?[index].description.toString() ?? "",
//                         maxLines: 3,

//                         style: TextStyle(
//                                                  color: (isHovered[videoId] ?? false) ? colorPrimary : Colors.white,

//                        fontSize: 14, height: 1.5),
//                         //overflow: TextOverflow.ellipsis
//                       )),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

  Widget languageLayout(int? typeId, List<Datum>? sectionDataList) {
    ScrollController _scrollController = ScrollController();
    void scrollBy(int elements) {
      _scrollController.animateTo(
        _scrollController.position.pixels +
            (elements * (Dimens.widthLand + 15)),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightLangGen,
      child: Stack(
        children: [
          ListView.separated(
            controller: _scrollController,
            itemCount: sectionDataList?.length ?? 0,
            shrinkWrap: true,
            physics: const PageScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.only(left: 20, right: 20),
            scrollDirection: Axis.horizontal,
            separatorBuilder: (context, index) => const SizedBox(width: 5),
            itemBuilder: (BuildContext context, int index) {
              return Stack(
                alignment: AlignmentDirectional.bottomStart,
                children: [
                  InkWell(
                    focusColor: white,
                    borderRadius: BorderRadius.circular(4),
                    onTap: () {
                      debugPrint("Clicked on index ==> $index");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return TVVideosByID(
                              sectionDataList?[index].id ?? 0,
                              typeId ?? 0,
                              sectionDataList?[index].name ?? "",
                              "ByLanguage",
                            );
                          },
                        ),
                      );
                    },
                    child: Container(
                      width: Dimens.widthLangGen,
                      height: Dimens.heightLangGen,
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
                      child: Stack(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: MyNetworkImage(
                              imageUrl:
                                  sectionDataList?[index].image.toString() ??
                                      "",
                              fit: BoxFit.fill,
                              imgHeight: MediaQuery.of(context).size.height,
                              imgWidth: MediaQuery.of(context).size.width,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(0),
                            width: MediaQuery.of(context).size.width,
                            height: Dimens.heightLangGen,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.center,
                                end: Alignment.bottomCenter,
                                colors: [
                                  transparentColor,
                                  transparentColor,
                                  appBgColor,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(3),
                    child: MyText(
                      color: white,
                      text: sectionDataList?[index].name.toString() ?? "",
                      textalign: TextAlign.center,
                      fontsizeNormal: 14,
                      fontweight: FontWeight.w600,
                      fontsizeWeb: 15,
                      multilanguage: false,
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            right: 16,
            top: 70,
            child: IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                ),
                onPressed: () {
                  scrollBy(5);
                }),
          ),
          Positioned(
            left: 16,
            top: 70,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onPressed: () {
                scrollBy(-5);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget genresLayout(int? typeId, List<Datum>? sectionDataList) {
    getAdaptiveTextSize(BuildContext context, dynamic value) {
      if (kIsWeb || Constant.isTV) {
        return (value / 650) *
            min(MediaQuery.of(context).size.height,
                MediaQuery.of(context).size.width);
      } else {
        return (value / 720 * MediaQuery.of(context).size.height);
      }
    }

    ScrollController _scrollController = ScrollController();
    void scrollBy(int elements) {
      _scrollController.animateTo(
        _scrollController.position.pixels +
            (elements * (Dimens.widthLand + 15)),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightLangGen,
      child: Stack(
        children: [
          ListView.separated(
            controller: _scrollController,
            itemCount: sectionDataList?.length ?? 0,
            shrinkWrap: true,
            physics: const PageScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.only(left: 70, right: 20),
            scrollDirection: Axis.horizontal,
            separatorBuilder: (context, index) => const SizedBox(width: 5),
            itemBuilder: (BuildContext context, int index) {
              return Stack(
                alignment: AlignmentDirectional.bottomStart,
                children: [
                  InkWell(
                      focusColor: white,
                      borderRadius: BorderRadius.circular(4),
                      onTap: () {
                        debugPrint("Clicked on index ==> $index");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return TVVideosByID(
                                sectionDataList?[index].id ?? 0,
                                typeId ?? 0,
                                sectionDataList?[index].name ?? "",
                                "ByCategory",
                              );
                            },
                          ),
                        );
                      },
                      child: Container(
                        width: Dimens.widthLangGen,
                        height: Dimens.heightLangGen,
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(bottom: 30, left: 22),
                        padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
                        child: Stack(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: MyNetworkImage(
                                imageUrl:
                                    sectionDataList?[index].image.toString() ??
                                        "",
                                fit: BoxFit.fill,
                                imgHeight: MediaQuery.of(context).size.height,
                                imgWidth: MediaQuery.of(context).size.width,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(0),
                              width: MediaQuery.of(context).size.width,
                              height: Dimens.heightLangGen,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.center,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    transparentColor,
                                    transparentColor,
                                    appBgColor,
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      )),

                  Positioned(
                    bottom: -8,
                    left: 0,
                    child: Container(
                      margin: EdgeInsets.only(left: 2, bottom: 10),
                      child: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text:
                                  sectionDataList?[index].name.toString()[0] ??
                                      "", // First letter
                              style: GoogleFonts.outfit(
                                fontSize: getAdaptiveTextSize(context,
                                    (kIsWeb || Constant.isTV) ? 40 : 40),
                                fontStyle: FontStyle.normal,
                                color: colorGraidentLeft,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: sectionDataList?[index]
                                      .name
                                      .toString()
                                      .substring(1) ??
                                  "", // Rest of the text
                              style: GoogleFonts.outfit(
                                fontSize: getAdaptiveTextSize(context,
                                    (kIsWeb || Constant.isTV) ? 15 : 17),
                                fontStyle: FontStyle.normal,
                                color: white,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  //--------

//   Positioned(
//   bottom: -8,
//   left: 0,
//   child: Container(
//      width: MediaQuery.of(context).size.width,
//     margin: EdgeInsets.only(left: 2, bottom: 10),
//     child: ShaderMask(
//       shaderCallback: (Rect bounds) {
//         return LinearGradient(
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//           colors: [colorPrimary, colorGraidentRight], // Replace with your desired gradient colors
//         ).createShader(bounds);
//       },
//       child: RichText(
//         text: TextSpan(
//           children: <TextSpan>[
//             TextSpan(
//               text: sectionDataList?[index].name.toString()[0] ?? "", // First letter
//               style: GoogleFonts.outfit(
//                 fontSize: getAdaptiveTextSize(context, (kIsWeb || Constant.isTV) ? 40 : 40),
//                 fontStyle: FontStyle.normal,
//                 color: white,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             TextSpan(
//               text: sectionDataList?[index].name.toString().substring(1) ?? "", // Rest of the text
//               style: GoogleFonts.outfit(
//                 fontSize: getAdaptiveTextSize(context, (kIsWeb || Constant.isTV) ? 15 : 17),
//                 fontStyle: FontStyle.normal,
//                 color: white,
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   ),
// ),

                  SizedBox(
                    height: 20,
                  ),
                ],
              );
            },
          ),
          Positioned(
            right: 16,
            top: 90,
            child: IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                ),
                onPressed: () {
                  scrollBy(5);
                }),
          ),
          Positioned(
            left: 16,
            top: 90,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onPressed: () {
                scrollBy(-5);
              },
            ),
          )
        ],
      ),
    );
  }

  Future<void> _buildLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          insetPadding: const EdgeInsets.fromLTRB(100, 25, 100, 25),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          backgroundColor: lightBlack,
          child: Container(
            padding: const EdgeInsets.all(25),
            constraints: const BoxConstraints(
              minWidth: 250,
              maxWidth: 300,
              minHeight: 100,
              maxHeight: 180,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: MyText(
                          color: white,
                          text: "confirmsognout",
                          multilanguage: true,
                          textalign: TextAlign.center,
                          fontsizeNormal: 16,
                          fontsizeWeb: 18,
                          fontweight: FontWeight.w500,
                          maxline: 2,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(),
                          child: MyText(
                            color: white,
                            text: "areyousurewanrtosignout",
                            multilanguage: true,
                            textalign: TextAlign.center,
                            fontsizeNormal: 12,
                            fontsizeWeb: 12,
                            fontweight: FontWeight.w300,
                            maxline: 2,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 33),
                Center(
                  child: Container(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Material(
                          type: MaterialType.transparency,
                          child: InkWell(
                            focusColor: white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(5),
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                constraints: const BoxConstraints(minWidth: 75),
                                height: 33,
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: otherColor,
                                    width: .4,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: MyText(
                                  color: white,
                                  text: "cancel",
                                  multilanguage: true,
                                  textalign: TextAlign.center,
                                  fontsizeNormal: 14,
                                  fontsizeWeb: 14,
                                  maxline: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontweight: FontWeight.w400,
                                  fontstyle: FontStyle.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 0),
                        Material(
                          type: MaterialType.transparency,
                          child: InkWell(
                            focusColor: white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(5),
                            onTap: () async {
                              // Firebase Signout
                              await auth.signOut();
                              await GoogleSignIn().signOut();
                              await Utils.setUserId(null);
                              await sectionDataProvider.clearProvider();
                              sectionDataProvider.getSectionBanner("0", "1");
                              sectionDataProvider.getSectionList("0", "1");
                              await homeProvider.homeNotifyProvider();
                              if (!mounted) return;
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                constraints: const BoxConstraints(minWidth: 75),
                                height: 33,
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: primaryLight,
                                  borderRadius: BorderRadius.circular(5),
                                  shape: BoxShape.rectangle,
                                ),
                                child: MyText(
                                  color: black,
                                  text: "sign_out",
                                  textalign: TextAlign.center,
                                  fontsizeNormal: 14,
                                  fontsizeWeb: 14,
                                  multilanguage: true,
                                  maxline: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontweight: FontWeight.w400,
                                  fontstyle: FontStyle.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /* ========= Open Player ========= */
  openPlayer(String playType, int index,
      List<ContinueWatching>? continueWatchingList) async {
    debugPrint("index ==========> $index");

    /* CHECK SUBSCRIPTION */
    if (playType != "Trailer") {
      bool? isPrimiumUser =
          await _checkSubsRentLogin(index, continueWatchingList);
      debugPrint("isPrimiumUser =============> $isPrimiumUser");
      if (!isPrimiumUser) return;
    }
    /* CHECK SUBSCRIPTION */

    if (!mounted) return;
    /* Set-up Quality URLs */
    Utils.setQualityURLs(
      video320: (continueWatchingList?[index].video320 ?? ""),
      video480: (continueWatchingList?[index].video480 ?? ""),
      video720: (continueWatchingList?[index].video720 ?? ""),
      video1080: (continueWatchingList?[index].video1080 ?? ""),
    );
    var isContinues = await Utils.openPlayer(
      context: context,
      playType:
          (continueWatchingList?[index].videoType ?? 0) == 2 ? "Show" : "Video",
      videoId: (continueWatchingList?[index].id ?? 0),
      videoType: continueWatchingList?[index].videoType ?? 0,
      typeId: continueWatchingList?[index].typeId ?? 0,
      otherId: (continueWatchingList?[index].videoType ?? 0) == 2
          ? (continueWatchingList?[index].showId ?? 0)
          : 0,
      videoUrl: continueWatchingList?[index].video320 ?? "",
      trailerUrl: continueWatchingList?[index].trailerUrl ?? "",
      uploadType: continueWatchingList?[index].videoUploadType ?? "",
      videoThumb: continueWatchingList?[index].landscape ?? "",
      vStopTime: continueWatchingList?[index].stopTime ?? 0,
    );
    if (isContinues != null && isContinues == true) {
      getTabData(0, homeProvider.sectionTypeModel.result);
      Future.delayed(Duration.zero).then((value) {
        if (!mounted) return;
        setState(() {});
      });
    }
  }

  Future<bool> _checkSubsRentLogin(
      int index, List<ContinueWatching>? continueWatchingList) async {
    if (Constant.userID != null) {
      if ((continueWatchingList?[index].isPremium ?? 0) == 1 &&
          (continueWatchingList?[index].isRent ?? 0) == 1) {
        if ((continueWatchingList?[index].isBuy ?? 0) == 1 ||
            (continueWatchingList?[index].rentBuy ?? 0) == 1) {
          return true;
        } else {
          dynamic isSubscribed = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const Subscription();
              },
            ),
          );
          if (isSubscribed != null && isSubscribed == true) {
            _getData();
          }
          return false;
        }
      } else if ((continueWatchingList?[index].isPremium ?? 0) == 1) {
        if ((continueWatchingList?[index].isBuy ?? 0) == 1) {
          return true;
        } else {
          dynamic isSubscribed = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const Subscription();
              },
            ),
          );
          if (isSubscribed != null && isSubscribed == true) {
            _getData();
          }
          return false;
        }
      } else if ((continueWatchingList?[index].isRent ?? 0) == 1) {
        if ((continueWatchingList?[index].rentBuy ?? 0) == 1) {
          return true;
        } else {
          dynamic isRented = await Utils.paymentForRent(
            context: context,
            videoId: continueWatchingList?[index].id.toString() ?? '',
            rentPrice: continueWatchingList?[index].rentPrice.toString() ?? '',
            vTitle: continueWatchingList?[index].name.toString() ?? '',
            typeId: continueWatchingList?[index].typeId.toString() ?? '',
            vType: continueWatchingList?[index].videoType.toString() ?? '',
          );
          if (isRented != null && isRented == true) {
            _getData();
          }
          return false;
        }
      } else {
        return true;
      }
    } else {
      if ((kIsWeb || Constant.isTV)) {
        Utils.buildWebAlertDialog(context, "login", "")
            .then((value) => _getData());
        return false;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const LoginSocial();
          },
        ),
      );
      return false;
    }
  }
  /* ========= Open Player ========= */
}
