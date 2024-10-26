import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

class LocationSelectionPage extends StatefulWidget {
  const LocationSelectionPage({super.key});

  @override
  State<LocationSelectionPage> createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  String? selectedCountry;
  String? selectedProvince;
  String? selectedCity;
  late bool _canGetLocation;
  String _currentLocation = "获取中...";

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      _canGetLocation = false;
      return Future.error('位置服务未开启');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        _canGetLocation = false;
        return Future.error('没有系统定位权限');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      _canGetLocation = false;
      return Future.error('系统定位权限请求被永久拒绝,无法请求权限');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _updateLocation() async {
    try {
      Position position = await _determinePosition();
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks.first;

      if (context.mounted) {
        setState(() {
          //_currentLocation = "${place.country} ${place.administrativeArea} ${place.locality} ${place.subLocality}";
          _canGetLocation = true;
          _currentLocation = " ${place.administrativeArea} ${place.locality} ";
        });
      }
    } catch (e) {
      if (context.mounted) {
        setState(() {
          _canGetLocation = false;
          _currentLocation = e.toString();
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _updateLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("选择地区"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text("当前定位"),
            trailing: SizedBox(
              width: 150,
              child: Text(
                _currentLocation,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            onTap: () {
              if (_canGetLocation == true) {
                GoRouter.of(context).pop(_currentLocation);
              }
            },
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children: _buildLocationList(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLocationList() {
    List<Widget> locationWidgets = [];

    // Example countries list
    List<String> countries = [
      "中国大陆",
      "阿尔及利亚",
      "中国香港",
      "中国澳门",
      "中国台湾",
      "阿尔巴尼亚",
      "阿富汗",
      "阿根廷",
      "阿拉伯联合酋长国",
      "阿鲁巴",
      "阿曼",
      "阿塞拜疆",
    ];

    // Example provinces for China
    List<String> provinces = [
      "北京",
      "天津",
      "河北",
      "山西",
      "内蒙古",
      "辽宁",
      "吉林",
      "黑龙江",
      "上海",
      "江苏",
      "浙江",
      "安徽",
      "福建",
      "江西",
      "山东",
      "河南",
      "湖北",
      "湖南",
      "广东",
      "广西",
      "海南",
      "重庆",
      "四川",
      "贵州",
      "云南",
      "西藏",
      "陕西",
      "甘肃",
      "青海",
      "宁夏",
      "新疆"
    ];

    // Example cities for each province
    Map<String, List<String>> cities = {
      "北京": ["北京市"],
      "天津": ["天津市"],
      "河北": [
        "石家庄",
        "唐山",
        "秦皇岛",
        "邯郸",
        "邢台",
        "保定",
        "张家口",
        "承德",
        "沧州",
        "廊坊",
        "衡水"
      ],
      "山西": ["太原", "大同", "阳泉", "长治", "晋城", "朔州", "晋中", "运城", "忻州", "临汾", "吕梁"],
      "内蒙古": [
        "呼和浩特",
        "包头",
        "乌海",
        "赤峰",
        "通辽",
        "鄂尔多斯",
        "呼伦贝尔",
        "巴彦淖尔",
        "乌兰察布",
        "兴安",
        "锡林郭勒",
        "阿拉善"
      ],
      "辽宁": [
        "沈阳",
        "大连",
        "鞍山",
        "抚顺",
        "本溪",
        "丹东",
        "锦州",
        "营口",
        "阜新",
        "辽阳",
        "盘锦",
        "铁岭",
        "朝阳",
        "葫芦岛"
      ],
      "吉林": ["长春", "吉林", "四平", "辽源", "通化", "白山", "松原", "白城", "延边"],
      "黑龙江": [
        "哈尔滨",
        "齐齐哈尔",
        "鸡西",
        "鹤岗",
        "双鸭山",
        "大庆",
        "伊春",
        "佳木斯",
        "七台河",
        "牡丹江",
        "黑河",
        "绥化",
        "大兴安岭"
      ],
      "上海": ["上海市"],
      "江苏": [
        "南京",
        "无锡",
        "徐州",
        "常州",
        "苏州",
        "南通",
        "连云港",
        "淮安",
        "盐城",
        "扬州",
        "镇江",
        "泰州",
        "宿迁"
      ],
      "浙江": ["杭州", "宁波", "温州", "嘉兴", "湖州", "绍兴", "金华", "衢州", "舟山", "台州", "丽水"],
      "安徽": [
        "合肥",
        "芜湖",
        "蚌埠",
        "淮南",
        "马鞍山",
        "淮北",
        "铜陵",
        "安庆",
        "黄山",
        "滁州",
        "阜阳",
        "宿州",
        "六安",
        "亳州",
        "池州",
        "宣城"
      ],
      "福建": ["福州", "厦门", "莆田", "三明", "泉州", "漳州", "南平", "龙岩", "宁德"],
      "江西": ["南昌", "景德镇", "萍乡", "九江", "新余", "鹰潭", "赣州", "吉安", "宜春", "抚州", "上饶"],
      "山东": [
        "济南",
        "青岛",
        "淄博",
        "枣庄",
        "东营",
        "烟台",
        "潍坊",
        "济宁",
        "泰安",
        "威海",
        "日照",
        "莱芜",
        "临沂",
        "德州",
        "聊城",
        "滨州",
        "菏泽"
      ],
      "河南": [
        "郑州",
        "开封",
        "洛阳",
        "平顶山",
        "安阳",
        "鹤壁",
        "新乡",
        "焦作",
        "濮阳",
        "许昌",
        "漯河",
        "三门峡",
        "南阳",
        "商丘",
        "信阳",
        "周口",
        "驻马店",
        "济源"
      ],
      "湖北": [
        "武汉",
        "黄石",
        "十堰",
        "宜昌",
        "襄阳",
        "鄂州",
        "荆门",
        "孝感",
        "荆州",
        "黄冈",
        "咸宁",
        "随州",
        "恩施"
      ],
      "湖南": [
        "长沙",
        "株洲",
        "湘潭",
        "衡阳",
        "邵阳",
        "岳阳",
        "常德",
        "张家界",
        "益阳",
        "郴州",
        "永州",
        "怀化",
        "娄底",
        "湘西"
      ],
      "广东": [
        "广州",
        "韶关",
        "深圳",
        "珠海",
        "汕头",
        "佛山",
        "江门",
        "湛江",
        "茂名",
        "肇庆",
        "惠州",
        "梅州",
        "汕尾",
        "河源",
        "阳江",
        "清远",
        "东莞",
        "中山",
        "潮州",
        "揭阳",
        "云浮"
      ],
      "广西": [
        "南宁",
        "柳州",
        "桂林",
        "梧州",
        "北海",
        "防城港",
        "钦州",
        "贵港",
        "玉林",
        "百色",
        "贺州",
        "河池",
        "来宾",
        "崇左"
      ],
      "海南": ["海口", "三亚", "三沙", "儋州"],
      "重庆": ["重庆市"],
      "四川": [
        "成都",
        "自贡",
        "攀枝花",
        "泸州",
        "德阳",
        "绵阳",
        "广元",
        "遂宁",
        "内江",
        "乐山",
        "南充",
        "眉山",
        "宜宾",
        "广安",
        "达州",
        "雅安",
        "巴中",
        "资阳",
        "阿坝",
        "甘孜",
        "凉山"
      ],
      "贵州": ["贵阳", "六盘水", "遵义", "安顺", "毕节", "铜仁", "黔西南", "黔东南", "黔南"],
      "云南": [
        "昆明",
        "曲靖",
        "玉溪",
        "保山",
        "昭通",
        "丽江",
        "普洱",
        "临沧",
        "楚雄",
        "红河",
        "文山",
        "西双版纳",
        "大理",
        "德宏",
        "怒江",
        "迪庆"
      ],
      "西藏": ["拉萨", "日喀则", "昌都", "林芝", "山南", "那曲", "阿里"],
      "陕西": ["西安", "铜川", "宝鸡", "咸阳", "渭南", "延安", "汉中", "榆林", "安康", "商洛"],
      "甘肃": [
        "兰州",
        "嘉峪关",
        "金昌",
        "白银",
        "天水",
        "武威",
        "张掖",
        "平凉",
        "酒泉",
        "庆阳",
        "定西",
        "陇南",
        "临夏",
        "甘南"
      ],
      "青海": ["西宁", "海东", "海北", "黄南", "海南", "果洛", "玉树", "海西"],
      "宁夏": ["银川", "石嘴山", "吴忠", "固原", "中卫"],
      "新疆": [
        "乌鲁木齐",
        "克拉玛依",
        "吐鲁番",
        "哈密",
        "昌吉",
        "博尔塔拉",
        "巴音郭楞",
        "阿克苏",
        "克孜勒苏",
        "喀什",
        "和田",
        "伊犁",
        "塔城",
        "阿勒泰"
      ]
    };

    if (selectedCountry == null) {
      // Show countries
      for (var country in countries) {
        locationWidgets.add(
          ListTile(
            title: Text(country),
            onTap: () {
              Future.delayed(Duration.zero, () {
                setState(() {
                  selectedCountry = country;
                });
              });
            },
          ),
        );
        locationWidgets.add(const Divider());
      }
    } else if (selectedCountry == "中国大陆" && selectedProvince == null) {
      // Show provinces if "中国大陆" is selected
      for (var province in provinces) {
        locationWidgets.add(
          ListTile(
            title: Text(province),
            onTap: () {
              Future.delayed(Duration.zero, () {
                setState(() {
                  selectedProvince = province;
                });
              });
            },
          ),
        );
        locationWidgets.add(const Divider());
      }
    } else if (selectedProvince != null && selectedCity == null) {
      // Show cities if a province is selected
      var cityList = cities[selectedProvince] ?? [];
      for (var city in cityList) {
        locationWidgets.add(
          ListTile(
            title: Text(city),
            onTap: () {
              Future.delayed(Duration.zero, () {
                setState(() {
                  selectedCity = city;
                });
                //
                //GoRouter.of(context).pop("$selectedProvince $selectedCity");
              });
            },
          ),
        );
        locationWidgets.add(const Divider());
      }
    } else {
      // 用户选择了非中国大陆国家或完成了中国大陆的选择
      Future.delayed(Duration.zero, () {
        if (selectedProvince != null && selectedCity != null) {
          if (mounted) {
            GoRouter.of(context)
                .pop("$selectedCountry $selectedProvince $selectedCity");
          }
        } else {
          if (mounted) {
            GoRouter.of(context).pop("$selectedCountry");
          }
        }
      });
    }

    return locationWidgets;
  }
}
