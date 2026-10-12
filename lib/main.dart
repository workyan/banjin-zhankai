import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _navy = Color(0xFF082C55);
const _blue = Color(0xFF0B68D1);
const _ink = Color(0xFF142033);
const _muted = Color(0xFF6F7C8F);
const _line = Color(0xFFE3E8EF);
const _surface = Color(0xFFF5F7FA);
const _screenshotChannel = MethodChannel('banjin_zhankai/screenshot_config');
final appStore = AppStore();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  await appStore.load();
  final screenshotScene = await resolveScreenshotScene();
  if (screenshotScene != null) appStore.seedScreenshotData();
  runApp(SheetMetalApp(screenshotScene: screenshotScene));
}

class SheetMetalApp extends StatelessWidget {
  const SheetMetalApp({super.key, this.screenshotScene});

  final ScreenshotScene? screenshotScene;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '钣金展开',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _blue,
          brightness: Brightness.light,
          surface: Colors.white,
        ),
        fontFamilyFallback: const [
          '.SF Pro Display',
          '.SF Pro Text',
          'PingFang SC',
        ],
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: _ink,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          titleMedium: TextStyle(
            color: _ink,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
          bodyMedium: TextStyle(color: _ink, fontSize: 15, height: 1.35),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {TargetPlatform.iOS: CupertinoPageTransitionsBuilder()},
        ),
      ),
      home: screenshotScene == null
          ? const AppShell()
          : ScreenshotScenePage(scene: screenshotScene!),
    );
  }
}

enum ScreenshotScene {
  homeOverview,
  calculatorInput,
  resultDimensions,
  resultPoints,
  projects,
  history,
  settings,
  bendInput,
  eccentricInput,
  elbowInput,
  teeInput,
  squareRoundInput,
  bendResult,
  elbowResult,
  teeResult,
  squareRoundResult;

  static ScreenshotScene? parse(String? value) {
    return switch (value) {
      'home-overview' => ScreenshotScene.homeOverview,
      'calculator-input' => ScreenshotScene.calculatorInput,
      'result-dimensions' => ScreenshotScene.resultDimensions,
      'result-points' => ScreenshotScene.resultPoints,
      'projects' => ScreenshotScene.projects,
      'history' => ScreenshotScene.history,
      'settings' => ScreenshotScene.settings,
      'bend-input' => ScreenshotScene.bendInput,
      'eccentric-input' => ScreenshotScene.eccentricInput,
      'elbow-input' => ScreenshotScene.elbowInput,
      'tee-input' => ScreenshotScene.teeInput,
      'square-round-input' => ScreenshotScene.squareRoundInput,
      'bend-result' => ScreenshotScene.bendResult,
      'elbow-result' => ScreenshotScene.elbowResult,
      'tee-result' => ScreenshotScene.teeResult,
      'square-round-result' => ScreenshotScene.squareRoundResult,
      _ => null,
    };
  }

  static ScreenshotScene? fromEnvironment() {
    final enabled = Platform.environment['APP_STORE_SCREENSHOT_MODE'];
    if (enabled != '1' && enabled?.toLowerCase() != 'true') return null;
    return parse(Platform.environment['APP_STORE_SCREENSHOT_SCENE']);
  }
}

Future<ScreenshotScene?> resolveScreenshotScene() async {
  final environmentScene = ScreenshotScene.fromEnvironment();
  if (environmentScene != null) return environmentScene;
  try {
    final scene = await _screenshotChannel.invokeMethod<String>(
      'getInitialScene',
    );
    return ScreenshotScene.parse(scene);
  } catch (_) {
    return null;
  }
}

class ConeResult {
  const ConeResult({
    required this.largeDiameter,
    required this.smallDiameter,
    required this.height,
    required this.thickness,
    required this.segments,
    required this.slant,
    required this.innerRadius,
    required this.outerRadius,
    required this.angle,
    required this.area,
  });

  final double largeDiameter;
  final double smallDiameter;
  final double height;
  final double thickness;
  final int segments;
  final double slant;
  final double innerRadius;
  final double outerRadius;
  final double angle;
  final double area;

  factory ConeResult.calculate({
    required double largeDiameter,
    required double smallDiameter,
    required double height,
    required double thickness,
    required int segments,
  }) {
    final radiusDifference = (largeDiameter - smallDiameter) / 2;
    final slant = math.sqrt(
      height * height + radiusDifference * radiusDifference,
    );
    final outerRadius = slant * largeDiameter / (largeDiameter - smallDiameter);
    final innerRadius = slant * smallDiameter / (largeDiameter - smallDiameter);
    final angle = 360 * (largeDiameter / 2) / outerRadius;
    final area =
        math.pi * (largeDiameter + smallDiameter) / 2 * slant / 1000000;
    return ConeResult(
      largeDiameter: largeDiameter,
      smallDiameter: smallDiameter,
      height: height,
      thickness: thickness,
      segments: segments,
      slant: slant,
      innerRadius: innerRadius,
      outerRadius: outerRadius,
      angle: angle,
      area: area,
    );
  }

  String get inputSummary =>
      'A ${largeDiameter.toStringAsFixed(0)} · B ${smallDiameter.toStringAsFixed(0)} · H ${height.toStringAsFixed(0)}';

  String report([int decimals = 1]) =>
      '同心圆锥台计算结果\n'
      '大端直径 A：${largeDiameter.toStringAsFixed(decimals)} mm\n'
      '小端直径 B：${smallDiameter.toStringAsFixed(decimals)} mm\n'
      '高度 H：${height.toStringAsFixed(decimals)} mm\n'
      '母线实长 L：${slant.toStringAsFixed(decimals)} mm\n'
      '扇形内半径 R₁：${innerRadius.toStringAsFixed(decimals)} mm\n'
      '扇形外半径 R₂：${outerRadius.toStringAsFixed(decimals)} mm\n'
      '圆心角 θ：${angle.toStringAsFixed(decimals)}°\n'
      '理论下料面积：${area.toStringAsFixed(3)} m²\n\n'
      '结果基于理想几何模型，实际加工前请结合板厚、咬口、焊缝和工艺余量复核。';
}

enum TemplateType { bend, eccentricCone, elbow, tee, squareRound }

class EngineeringResult {
  const EngineeringResult({
    required this.type,
    required this.title,
    required this.asset,
    required this.inputSummary,
    required this.inputs,
    required this.metrics,
    required this.points,
    required this.note,
  });

  final TemplateType type;
  final String title;
  final String asset;
  final String inputSummary;
  final Map<String, double> inputs;
  final List<(String, double, String)> metrics;
  final List<double> points;
  final String note;

  String report(int decimals) {
    final buffer = StringBuffer('$title计算结果\n$inputSummary\n');
    for (final metric in metrics) {
      buffer.writeln(
        '${metric.$1}：${metric.$2.toStringAsFixed(_metricDecimals(metric.$3, decimals))} ${metric.$3}',
      );
    }
    if (points.isNotEmpty) {
      buffer
        ..writeln('\n等分点实长/高度（mm）')
        ..writeln(
          points
              .asMap()
              .entries
              .map(
                (item) =>
                    '${item.key + 1}: ${item.value.toStringAsFixed(decimals)}',
              )
              .join('  '),
        );
    }
    buffer.write('\n$note\n实际加工前请结合板厚、接缝与工艺余量复核。');
    return buffer.toString();
  }

  static int _metricDecimals(String unit, int decimals) {
    if (unit == 'm²') return 3;
    if (unit == '段' || unit == '节') return 0;
    return decimals;
  }

  Map<String, Object> toJson() => {
    'type': type.name,
    'title': title,
    'asset': asset,
    'inputSummary': inputSummary,
    'inputs': inputs,
    'metrics': metrics.map((item) => [item.$1, item.$2, item.$3]).toList(),
    'points': points,
    'note': note,
  };

  factory EngineeringResult.fromJson(Map<String, dynamic> json) =>
      EngineeringResult(
        type: TemplateType.values.byName(json['type'] as String),
        title: json['title'] as String,
        asset: json['asset'] as String,
        inputSummary: json['inputSummary'] as String,
        inputs: (json['inputs'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
        metrics: (json['metrics'] as List<dynamic>)
            .map(
              (item) => (
                (item as List<dynamic>)[0] as String,
                (item[1] as num).toDouble(),
                item[2] as String,
              ),
            )
            .toList(),
        points: (json['points'] as List<dynamic>)
            .map((item) => (item as num).toDouble())
            .toList(),
        note: json['note'] as String,
      );
}

class EngineeringMath {
  const EngineeringMath._();

  static EngineeringResult bend(Map<String, double> value) {
    final legA = value['legA']!;
    final legB = value['legB']!;
    final radius = value['radius']!;
    final thickness = value['thickness']!;
    final angle = value['angle']!;
    final kFactor = value['kFactor']!;
    final radians = angle * math.pi / 180;
    final allowance = radians * (radius + kFactor * thickness);
    final setback = (radius + thickness) * math.tan(radians / 2);
    final deduction = 2 * setback - allowance;
    final flat = legA + legB - deduction;
    return EngineeringResult(
      type: TemplateType.bend,
      title: '单折弯展开',
      asset: 'assets/components/elbow.png',
      inputSummary:
          'A ${legA.toStringAsFixed(0)} · B ${legB.toStringAsFixed(0)} · ${angle.toStringAsFixed(0)}°',
      inputs: value,
      metrics: [
        ('折弯余量 BA', allowance, 'mm'),
        ('单边退让 SB', setback, 'mm'),
        ('折弯扣除 BD', deduction, 'mm'),
        ('展开总长 L', flat, 'mm'),
      ],
      points: const [],
      note: '按中性层 K 因子法计算，A、B 为成形后的外侧边长。',
    );
  }

  static EngineeringResult eccentricCone(Map<String, double> value) {
    final large = value['large']!;
    final small = value['small']!;
    final height = value['height']!;
    final offset = value['offset']!;
    final segments = value['segments']!.round();
    final largeRadius = large / 2;
    final smallRadius = small / 2;
    final points = <double>[];
    for (int i = 0; i <= segments; i++) {
      final angle = 2 * math.pi * i / segments;
      final dx =
          largeRadius * math.cos(angle) -
          (offset + smallRadius * math.cos(angle));
      final dy = largeRadius * math.sin(angle) - smallRadius * math.sin(angle);
      points.add(math.sqrt(height * height + dx * dx + dy * dy));
    }
    final mean = points.reduce((a, b) => a + b) / points.length;
    final area = math.pi * (large + small) / 2 * mean / 1000000;
    return EngineeringResult(
      type: TemplateType.eccentricCone,
      title: '偏心圆锥台',
      asset: 'assets/components/conical_frustum.png',
      inputSummary:
          'D ${large.toStringAsFixed(0)} · d ${small.toStringAsFixed(0)} · e ${offset.toStringAsFixed(0)}',
      inputs: value,
      metrics: [
        ('最短素线', points.reduce(math.min), 'mm'),
        ('最长素线', points.reduce(math.max), 'mm'),
        ('平均素线', mean, 'mm'),
        ('理论侧面积', area, 'm²'),
      ],
      points: points,
      note: '采用对应母线三角形法，点位从偏心方向起按圆周等分。',
    );
  }

  static EngineeringResult elbow(Map<String, double> value) {
    final diameter = value['diameter']!;
    final radius = value['radius']!;
    final angle = value['angle']!;
    final pieces = value['pieces']!.round();
    final circumference = math.pi * diameter;
    final jointAngle = angle / (2 * (pieces - 1));
    final amplitude = diameter / 2 * math.tan(jointAngle * math.pi / 180);
    final centerPitch =
        2 * radius * math.tan(angle * math.pi / 180 / (2 * (pieces - 1)));
    final points = List<double>.generate(
      13,
      (i) => centerPitch / 2 + amplitude * math.cos(2 * math.pi * i / 12),
    );
    return EngineeringResult(
      type: TemplateType.elbow,
      title: '${angle.toStringAsFixed(0)}°虾米腰弯头',
      asset: 'assets/components/elbow.png',
      inputSummary:
          'D ${diameter.toStringAsFixed(0)} · R ${radius.toStringAsFixed(0)} · $pieces 节',
      inputs: value,
      metrics: [
        ('圆周展开宽度', circumference, 'mm'),
        ('相邻节转角', angle / (pieces - 1), '°'),
        ('接口斜切角', jointAngle, '°'),
        ('中心节轴向节距', centerPitch, 'mm'),
        ('切口高差', amplitude * 2, 'mm'),
      ],
      points: points,
      note: '按等角虾米腰、两端半节模型计算，点位为管周 12 等分切口高度。',
    );
  }

  static EngineeringResult tee(Map<String, double> value) {
    final mainDiameter = value['mainDiameter']!;
    final branchDiameter = value['branchDiameter']!;
    final angle = value['angle']!;
    final segments = value['segments']!.round();
    final mainRadius = mainDiameter / 2;
    final branchRadius = branchDiameter / 2;
    final intersectionAngle = angle * math.pi / 180;
    final points = <double>[];
    for (int i = 0; i <= segments; i++) {
      final phi = 2 * math.pi * i / segments;
      final lateral = branchRadius * math.cos(phi);
      final root = math.sqrt(
        math.max(0, mainRadius * mainRadius - lateral * lateral),
      );
      final height =
          (root - branchRadius * math.sin(phi) * math.cos(intersectionAngle)) /
          math.sin(intersectionAngle);
      points.add(height);
    }
    final minimum = points.reduce(math.min);
    final shifted = points.map((item) => item - minimum).toList();
    return EngineeringResult(
      type: TemplateType.tee,
      title: '${angle.toStringAsFixed(0)}°圆管相贯',
      asset: 'assets/components/tee.png',
      inputSummary:
          '主管 ${mainDiameter.toStringAsFixed(0)} · 支管 ${branchDiameter.toStringAsFixed(0)} · ${angle.toStringAsFixed(0)}°',
      inputs: value,
      metrics: [
        ('支管展开宽度', math.pi * branchDiameter, 'mm'),
        ('相贯线最大高度', shifted.reduce(math.max), 'mm'),
        ('等分数', segments.toDouble(), '段'),
      ],
      points: shifted,
      note: '按两圆柱轴线相交的解析模型计算，点位从支管圆周基准点开始。',
    );
  }

  static EngineeringResult squareRound(Map<String, double> value) {
    final width = value['width']!;
    final depth = value['depth']!;
    final diameter = value['diameter']!;
    final height = value['height']!;
    final offsetX = value['offsetX']!;
    final offsetY = value['offsetY']!;
    final segments = value['segments']!.round();
    final rectanglePerimeter = 2 * (width + depth);
    final circleRadius = diameter / 2;
    final points = <double>[];
    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      final rectangle = _rectanglePoint(width, depth, t);
      final angle = 2 * math.pi * t;
      final circle = Offset(
        offsetX + circleRadius * math.cos(angle),
        offsetY + circleRadius * math.sin(angle),
      );
      final dx = rectangle.dx - circle.dx;
      final dy = rectangle.dy - circle.dy;
      points.add(math.sqrt(height * height + dx * dx + dy * dy));
    }
    final stripA = rectanglePerimeter / segments;
    final stripB = math.pi * diameter / segments;
    double area = 0;
    for (int i = 0; i < segments; i++) {
      area += (stripA + stripB) / 2 * (points[i] + points[i + 1]) / 2;
    }
    return EngineeringResult(
      type: TemplateType.squareRound,
      title: offsetX == 0 && offsetY == 0 ? '同心天圆地方' : '偏心天圆地方',
      asset: 'assets/components/square_round.png',
      inputSummary:
          '${width.toStringAsFixed(0)}×${depth.toStringAsFixed(0)} · Ø${diameter.toStringAsFixed(0)} · H ${height.toStringAsFixed(0)}',
      inputs: value,
      metrics: [
        ('最短素线', points.reduce(math.min), 'mm'),
        ('最长素线', points.reduce(math.max), 'mm'),
        ('方口周长', rectanglePerimeter, 'mm'),
        ('圆口周长', math.pi * diameter, 'mm'),
        ('理论侧面积', area / 1000000, 'm²'),
      ],
      points: points,
      note: '按方口与圆口周长等分的三角形法计算，点位从方口右上方向顺时针编号。',
    );
  }

  static Offset _rectanglePoint(double width, double depth, double t) {
    final perimeter = 2 * (width + depth);
    var distance = (t * perimeter) % perimeter;
    if (distance <= width) {
      return Offset(width / 2 - distance, -depth / 2);
    }
    distance -= width;
    if (distance <= depth) {
      return Offset(-width / 2, -depth / 2 + distance);
    }
    distance -= depth;
    if (distance <= width) {
      return Offset(-width / 2 + distance, depth / 2);
    }
    distance -= width;
    return Offset(width / 2, depth / 2 - distance);
  }
}

class HistoryEntry {
  HistoryEntry({
    required this.id,
    required this.title,
    required this.summary,
    required this.createdAt,
    required this.result,
  });

  final String id;
  final String title;
  final String summary;
  final DateTime createdAt;
  final ConeResult result;

  Map<String, Object> toJson() => {
    'id': id,
    'title': title,
    'summary': summary,
    'createdAt': createdAt.toIso8601String(),
    'largeDiameter': result.largeDiameter,
    'smallDiameter': result.smallDiameter,
    'height': result.height,
    'thickness': result.thickness,
    'segments': result.segments,
  };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    final result = ConeResult.calculate(
      largeDiameter: (json['largeDiameter'] as num).toDouble(),
      smallDiameter: (json['smallDiameter'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      thickness: (json['thickness'] as num).toDouble(),
      segments: (json['segments'] as num).toInt(),
    );
    return HistoryEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      result: result,
    );
  }
}

class EngineeringEntry {
  EngineeringEntry({
    required this.id,
    required this.createdAt,
    required this.result,
  });

  final String id;
  final DateTime createdAt;
  final EngineeringResult result;

  Map<String, Object> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'result': result.toJson(),
  };

  factory EngineeringEntry.fromJson(Map<String, dynamic> json) =>
      EngineeringEntry(
        id: json['id'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        result: EngineeringResult.fromJson(
          json['result'] as Map<String, dynamic>,
        ),
      );
}

class AppStore extends ChangeNotifier {
  static const _historyKey = 'calculation_history_v1';
  static const _projectsKey = 'saved_components_v1';
  static const _favoritesKey = 'favorites_v1';
  static const _decimalsKey = 'decimals_v1';
  static const _engineeringHistoryKey = 'engineering_history_v1';
  static const _engineeringProjectsKey = 'engineering_projects_v1';

  SharedPreferences? _prefs;
  final List<HistoryEntry> history = [];
  final List<HistoryEntry> savedComponents = [];
  final List<EngineeringEntry> engineeringHistory = [];
  final List<EngineeringEntry> savedEngineering = [];
  final Set<String> favorites = {'同心圆锥台', '同心天圆地方'};
  int decimals = 1;

  void seedScreenshotData() {
    history.clear();
    savedComponents.clear();
    engineeringHistory.clear();
    savedEngineering.clear();

    final cone = ConeResult.calculate(
      largeDiameter: 1200,
      smallDiameter: 680,
      height: 920,
      thickness: 2,
      segments: 24,
    );
    final bend = EngineeringMath.bend({
      'legA': 180,
      'legB': 240,
      'radius': 4,
      'thickness': 2,
      'angle': 90,
      'kFactor': 0.42,
    });
    final elbow = EngineeringMath.elbow({
      'diameter': 600,
      'radius': 900,
      'angle': 90,
      'pieces': 5,
    });
    final now = DateTime(2026, 8, 26, 9, 30);
    history.add(
      HistoryEntry(
        id: 'screenshot-cone-history',
        title: '同心圆锥台',
        summary: cone.inputSummary,
        createdAt: now.subtract(const Duration(minutes: 18)),
        result: cone,
      ),
    );
    savedComponents.add(
      HistoryEntry(
        id: 'screenshot-cone-project',
        title: '除尘管道变径节',
        summary: cone.inputSummary,
        createdAt: now.subtract(const Duration(days: 1)),
        result: cone,
      ),
    );
    engineeringHistory.addAll([
      EngineeringEntry(
        id: 'screenshot-bend-history',
        createdAt: now.subtract(const Duration(hours: 2)),
        result: bend,
      ),
      EngineeringEntry(
        id: 'screenshot-elbow-history',
        createdAt: now.subtract(const Duration(days: 2)),
        result: elbow,
      ),
    ]);
    savedEngineering.addAll([
      EngineeringEntry(
        id: 'screenshot-bend-project',
        createdAt: now.subtract(const Duration(days: 3)),
        result: bend,
      ),
      EngineeringEntry(
        id: 'screenshot-elbow-project',
        createdAt: now.subtract(const Duration(days: 4)),
        result: elbow,
      ),
    ]);
  }

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    decimals = _prefs?.getInt(_decimalsKey) ?? 1;
    favorites
      ..clear()
      ..addAll(_prefs?.getStringList(_favoritesKey) ?? ['同心圆锥台', '同心天圆地方']);
    final raw = _prefs?.getStringList(_historyKey) ?? const [];
    for (final item in raw) {
      try {
        history.add(
          HistoryEntry.fromJson(jsonDecode(item) as Map<String, dynamic>),
        );
      } catch (_) {
        // Ignore data written by an incompatible pre-release build.
      }
    }
    final saved = _prefs?.getStringList(_projectsKey) ?? const [];
    for (final item in saved) {
      try {
        savedComponents.add(
          HistoryEntry.fromJson(jsonDecode(item) as Map<String, dynamic>),
        );
      } catch (_) {
        // Ignore data written by an incompatible pre-release build.
      }
    }
    for (final item
        in _prefs?.getStringList(_engineeringHistoryKey) ?? const []) {
      try {
        engineeringHistory.add(
          EngineeringEntry.fromJson(jsonDecode(item) as Map<String, dynamic>),
        );
      } catch (_) {
        // Ignore incompatible pre-release data.
      }
    }
    for (final item
        in _prefs?.getStringList(_engineeringProjectsKey) ?? const []) {
      try {
        savedEngineering.add(
          EngineeringEntry.fromJson(jsonDecode(item) as Map<String, dynamic>),
        );
      } catch (_) {
        // Ignore incompatible pre-release data.
      }
    }
  }

  Future<void> addHistory(ConeResult result) async {
    history.insert(
      0,
      HistoryEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: '同心圆锥台',
        summary: result.inputSummary,
        createdAt: DateTime.now(),
        result: result,
      ),
    );
    if (history.length > 100) history.removeRange(100, history.length);
    await _saveHistory();
    notifyListeners();
  }

  Future<void> deleteHistory(String id) async {
    history.removeWhere((item) => item.id == id);
    await _saveHistory();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    history.clear();
    engineeringHistory.clear();
    await _saveHistory();
    await _saveEngineering(_engineeringHistoryKey, engineeringHistory);
    notifyListeners();
  }

  Future<void> addToProject(ConeResult result) async {
    savedComponents.insert(
      0,
      HistoryEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: '同心圆锥台',
        summary: result.inputSummary,
        createdAt: DateTime.now(),
        result: result,
      ),
    );
    await _prefs?.setStringList(
      _projectsKey,
      savedComponents.map((item) => jsonEncode(item.toJson())).toList(),
    );
    notifyListeners();
  }

  Future<void> addEngineeringHistory(EngineeringResult result) async {
    engineeringHistory.insert(
      0,
      EngineeringEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        result: result,
      ),
    );
    if (engineeringHistory.length > 100) {
      engineeringHistory.removeRange(100, engineeringHistory.length);
    }
    await _saveEngineering(_engineeringHistoryKey, engineeringHistory);
    notifyListeners();
  }

  Future<void> addEngineeringToProject(EngineeringResult result) async {
    savedEngineering.insert(
      0,
      EngineeringEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        result: result,
      ),
    );
    await _saveEngineering(_engineeringProjectsKey, savedEngineering);
    notifyListeners();
  }

  Future<void> deleteEngineeringHistory(String id) async {
    engineeringHistory.removeWhere((item) => item.id == id);
    await _saveEngineering(_engineeringHistoryKey, engineeringHistory);
    notifyListeners();
  }

  Future<void> toggleFavorite(String name) async {
    favorites.contains(name) ? favorites.remove(name) : favorites.add(name);
    await _prefs?.setStringList(_favoritesKey, favorites.toList());
    notifyListeners();
  }

  Future<void> setDecimals(int value) async {
    decimals = value;
    await _prefs?.setInt(_decimalsKey, value);
    notifyListeners();
  }

  Future<void> _saveHistory() async {
    await _prefs?.setStringList(
      _historyKey,
      history.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  Future<void> _saveEngineering(
    String key,
    List<EngineeringEntry> entries,
  ) async {
    await _prefs?.setStringList(
      key,
      entries.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }
}

class ScreenshotScenePage extends StatelessWidget {
  const ScreenshotScenePage({super.key, required this.scene});

  final ScreenshotScene scene;

  @override
  Widget build(BuildContext context) {
    return switch (scene) {
      ScreenshotScene.homeOverview => const AppShell(initialIndex: 0),
      ScreenshotScene.calculatorInput => const CalculatorPage(),
      ScreenshotScene.resultDimensions => const ResultPage(initialMode: 1),
      ScreenshotScene.resultPoints => const ResultPage(initialMode: 2),
      ScreenshotScene.projects => const AppShell(initialIndex: 1),
      ScreenshotScene.history => const AppShell(initialIndex: 2),
      ScreenshotScene.settings => const AppShell(initialIndex: 3),
      ScreenshotScene.bendInput => const GenericCalculatorPage(
        type: TemplateType.bend,
      ),
      ScreenshotScene.eccentricInput => const GenericCalculatorPage(
        type: TemplateType.eccentricCone,
      ),
      ScreenshotScene.elbowInput => const GenericCalculatorPage(
        type: TemplateType.elbow,
      ),
      ScreenshotScene.teeInput => const GenericCalculatorPage(
        type: TemplateType.tee,
      ),
      ScreenshotScene.squareRoundInput => const GenericCalculatorPage(
        type: TemplateType.squareRound,
      ),
      ScreenshotScene.bendResult => GenericResultPage(
        result: EngineeringMath.bend({
          'legA': 300,
          'legB': 200,
          'radius': 3,
          'thickness': 2,
          'angle': 90,
          'kFactor': .4,
        }),
      ),
      ScreenshotScene.elbowResult => GenericResultPage(
        result: EngineeringMath.elbow({
          'diameter': 500,
          'radius': 750,
          'angle': 90,
          'pieces': 4,
        }),
      ),
      ScreenshotScene.teeResult => GenericResultPage(
        result: EngineeringMath.tee({
          'mainDiameter': 600,
          'branchDiameter': 400,
          'angle': 90,
          'segments': 12,
        }),
      ),
      ScreenshotScene.squareRoundResult => GenericResultPage(
        result: EngineeringMath.squareRound({
          'width': 800,
          'depth': 600,
          'diameter': 500,
          'height': 700,
          'offsetX': 0,
          'offsetY': 0,
          'segments': 16,
        }),
      ),
    };
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _tab;

  static const _pages = [
    ExpandHome(),
    ProjectsPage(),
    HistoryPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _tab = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 64,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: _line, width: .7)),
          ),
          child: Row(
            children: [
              _NavItem(
                label: '展开',
                icon: CupertinoIcons.square_grid_2x2,
                selected: _tab == 0,
                onTap: () => setState(() => _tab = 0),
              ),
              _NavItem(
                label: '项目',
                icon: CupertinoIcons.folder,
                selected: _tab == 1,
                onTap: () => setState(() => _tab = 1),
              ),
              _NavItem(
                label: '历史',
                icon: CupertinoIcons.clock,
                selected: _tab == 2,
                onTap: () => setState(() => _tab = 2),
              ),
              _NavItem(
                label: '设置',
                icon: CupertinoIcons.gear,
                selected: _tab == 3,
                onTap: () => setState(() => _tab = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? _blue : const Color(0xFF7B899B);
    return Expanded(
      child: InkResponse(
        onTap: onTap,
        highlightShape: BoxShape.rectangle,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: selected ? 30 : 26,
              height: 27,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFEAF3FF) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 21, color: color),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void openTemplate(BuildContext context, String name) {
  if (name == '同心圆锥台' || name == '锥台') {
    Navigator.of(
      context,
    ).push(CupertinoPageRoute<void>(builder: (_) => const CalculatorPage()));
    return;
  }
  final type = switch (name) {
    '折弯' || '单折弯' => TemplateType.bend,
    '偏心大小头' || '偏心圆锥台' => TemplateType.eccentricCone,
    '弯头' || '90°弯头' || '虾米腰' || '90°虾米腰弯头' => TemplateType.elbow,
    '三通' || '圆管三通' || '三通正交' || '等径圆管三通' || '相贯' => TemplateType.tee,
    '天圆地方' || '方圆过渡' || '同心天圆地方' || '单偏心天圆地方' => TemplateType.squareRound,
    _ => TemplateType.bend,
  };
  Navigator.of(context).push(
    CupertinoPageRoute<void>(
      builder: (_) =>
          GenericCalculatorPage(type: type, eccentric: name.contains('偏心')),
    ),
  );
}

Future<void> shareText(BuildContext context, String text) async {
  try {
    final renderBox = context.findRenderObject();
    final origin = renderBox is RenderBox && renderBox.hasSize
        ? renderBox.localToGlobal(Offset.zero) & renderBox.size
        : Offset.zero & MediaQuery.sizeOf(context);
    final result = await SharePlus.instance.share(
      ShareParams(text: text, sharePositionOrigin: origin),
    );
    if (!context.mounted) return;
    if (result.status == ShareResultStatus.unavailable) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('当前设备没有可用的分享方式')));
    }
  } on PlatformException catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('无法打开系统分享：${error.message ?? '请稍后重试'}')),
    );
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('无法打开系统分享，请稍后重试')));
  }
}

class ExpandHome extends StatefulWidget {
  const ExpandHome({super.key});

  @override
  State<ExpandHome> createState() => _ExpandHomeState();
}

class _ExpandHomeState extends State<ExpandHome> {
  static const _recent = [
    _Component('同心圆锥台', 'assets/components/conical_frustum.png'),
    _Component('天圆地方', 'assets/components/square_round.png'),
    _Component('90°弯头', 'assets/components/elbow.png'),
    _Component('圆管三通', 'assets/components/tee.png'),
  ];

  static const _favorites = [
    _Component('偏心大小头', 'assets/components/conical_frustum.png'),
    _Component('方圆过渡', 'assets/components/square_round.png'),
    _Component('三通正交', 'assets/components/tee.png'),
    _Component('虾米腰', 'assets/components/elbow.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: const Color(0xFF092C55),
        child: SafeArea(
          bottom: false,
          child: ColoredBox(
            color: Colors.white,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _SearchHeader(onSearch: () => _openSearch(context)),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 21, 18, 30),
                  sliver: SliverList.list(
                    children: [
                      _SectionHeader(
                        title: '最近使用',
                        action: '全部',
                        onAction: () =>
                            _openCollection(context, '最近使用', _recent),
                      ),
                      const SizedBox(height: 12),
                      _ComponentRow(items: _recent),
                      const SizedBox(height: 26),
                      _SectionHeader(
                        title: '收藏',
                        action: '全部',
                        onAction: () =>
                            _openCollection(context, '收藏', _favorites),
                      ),
                      const SizedBox(height: 12),
                      _ComponentRow(items: _favorites, favorite: true),
                      const SizedBox(height: 28),
                      const _SectionHeader(title: '常用分类'),
                      const SizedBox(height: 13),
                      const _CategoryGrid(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openSearch(BuildContext context) {
    showSearch<void>(
      context: context,
      delegate: _ComponentSearchDelegate(
        onOpen: (name) => openTemplate(context, name),
      ),
    );
  }

  void _openCollection(
    BuildContext context,
    String title,
    List<_Component> items,
  ) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => _TemplateCollectionPage(title: title, items: items),
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({required this.onSearch});

  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF092C55), Color(0xFF0D4379)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Semantics(
        button: true,
        label: '搜索构件、俗称',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onSearch,
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .96),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Row(
              children: [
                SizedBox(width: 14),
                Icon(CupertinoIcons.search, size: 19, color: _muted),
                SizedBox(width: 9),
                Text(
                  '搜索构件、俗称',
                  style: TextStyle(color: Color(0xFF8A94A5), fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ComponentSearchDelegate extends SearchDelegate<void> {
  _ComponentSearchDelegate({required this.onOpen});

  final ValueChanged<String> onOpen;

  static const items = [
    ('同心圆锥台', '圆锥 大小头 锥台', 'assets/components/conical_frustum.png'),
    ('偏心圆锥台', '偏心 大小头', 'assets/components/conical_frustum.png'),
    ('同心天圆地方', '方圆过渡 天方地圆', 'assets/components/square_round.png'),
    ('单偏心天圆地方', '方圆过渡 偏心', 'assets/components/square_round.png'),
    ('90°虾米腰弯头', '弯头 圆管 虾米腰', 'assets/components/elbow.png'),
    ('等径圆管三通', '三通 正交 T型 相贯', 'assets/components/tee.png'),
    ('单折弯', '折弯 展开 K因子', 'assets/components/elbow.png'),
  ];

  @override
  String get searchFieldLabel => '搜索构件、俗称';

  @override
  List<Widget> buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear)),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    onPressed: () => close(context, null),
    icon: const Icon(CupertinoIcons.chevron_left),
  );

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final keyword = query.trim().toLowerCase();
    final results = items
        .where(
          (item) =>
              keyword.isEmpty ||
              '${item.$1} ${item.$2}'.toLowerCase().contains(keyword),
        )
        .toList();
    if (results.isEmpty) {
      return const Center(child: Text('没有找到构件，试试“弯头”或“大小头”'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(18),
      itemCount: results.length,
      separatorBuilder: (_, _) => const Divider(height: 1, color: _line),
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 7),
          leading: SizedBox(
            width: 58,
            height: 58,
            child: Image.asset(item.$3, fit: BoxFit.contain),
          ),
          title: Text(
            item.$1,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: const Text('参数输入 · 展开数据 · 点位图'),
          trailing: const Icon(
            CupertinoIcons.chevron_right,
            size: 17,
            color: _blue,
          ),
          onTap: () {
            close(context, null);
            onOpen(item.$1);
          },
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _ink,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -.2,
          ),
        ),
        const Spacer(),
        if (action != null)
          CupertinoButton(
            padding: const EdgeInsets.fromLTRB(12, 8, 0, 8),
            minimumSize: const Size(44, 44),
            onPressed: onAction,
            child: Row(
              children: [
                Text(
                  action!,
                  style: const TextStyle(color: _muted, fontSize: 13),
                ),
                const SizedBox(width: 2),
                const Icon(
                  CupertinoIcons.chevron_right,
                  size: 14,
                  color: _muted,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Component {
  const _Component(this.name, this.asset);

  final String name;
  final String asset;
}

class _TemplateCollectionPage extends StatelessWidget {
  const _TemplateCollectionPage({required this.title, required this.items});

  final String title;
  final List<_Component> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(CupertinoIcons.chevron_left),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        itemCount: items.length,
        separatorBuilder: (_, _) => const Divider(height: 1, color: _line),
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            leading: SizedBox(
              width: 64,
              height: 64,
              child: Image.asset(item.asset, fit: BoxFit.contain),
            ),
            title: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text('参数输入 · 展开数据 · 点位图'),
            trailing: const Icon(
              CupertinoIcons.chevron_right,
              size: 17,
              color: _muted,
            ),
            onTap: () => openTemplate(context, item.name),
          );
        },
      ),
    );
  }
}

class _ComponentRow extends StatelessWidget {
  const _ComponentRow({required this.items, this.favorite = false});

  final List<_Component> items;
  final bool favorite;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          Expanded(
            child: _ComponentTile(
              component: items[i],
              favorite: favorite,
              onTap: () => openTemplate(context, items[i].name),
            ),
          ),
          if (i != items.length - 1) const SizedBox(width: 9),
        ],
      ],
    );
  }
}

class _ComponentTile extends StatefulWidget {
  const _ComponentTile({
    required this.component,
    required this.favorite,
    required this.onTap,
  });

  final _Component component;
  final bool favorite;
  final VoidCallback onTap;

  @override
  State<_ComponentTile> createState() => _ComponentTileState();
}

class _ComponentTileState extends State<_ComponentTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? .96 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 119,
          padding: const EdgeInsets.fromLTRB(7, 8, 7, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: _line),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D153354),
                blurRadius: 13,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Hero(
                      tag: '${widget.component.asset}-${widget.component.name}',
                      child: Image.asset(
                        widget.component.asset,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.component.name,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (widget.favorite)
                const Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(
                    CupertinoIcons.star_fill,
                    color: Color(0xFFFFB000),
                    size: 14,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid();

  @override
  Widget build(BuildContext context) {
    const categories = [
      ('折弯', CupertinoIcons.wand_stars, null),
      ('弯头', null, 'assets/components/elbow.png'),
      ('三通', null, 'assets/components/tee.png'),
      ('锥台', null, 'assets/components/conical_frustum.png'),
      ('方圆过渡', null, 'assets/components/square_round.png'),
      ('相贯', CupertinoIcons.link, null),
    ];
    return GridView.builder(
      itemCount: categories.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 11,
        crossAxisSpacing: 11,
        childAspectRatio: 1.16,
      ),
      itemBuilder: (context, index) {
        final item = categories[index];
        return Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: _line),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => openTemplate(context, item.$1),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(9, 8, 9, 7),
              child: Column(
                children: [
                  Expanded(
                    child: item.$3 != null
                        ? Image.asset(item.$3!, fit: BoxFit.contain)
                        : Icon(item.$2, color: _navy, size: 31),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.$1,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GenericSpec {
  const _GenericSpec(
    this.key,
    this.label,
    this.unit,
    this.example, {
    this.integer = false,
    this.signed = false,
  });

  final String key;
  final String label;
  final String unit;
  final String example;
  final bool integer;
  final bool signed;
}

class GenericCalculatorPage extends StatefulWidget {
  const GenericCalculatorPage({
    super.key,
    required this.type,
    this.eccentric = false,
  });

  final TemplateType type;
  final bool eccentric;

  @override
  State<GenericCalculatorPage> createState() => _GenericCalculatorPageState();
}

class _GenericCalculatorPageState extends State<GenericCalculatorPage> {
  late final List<_GenericSpec> _specs;
  late final List<TextEditingController> _controllers;
  String? _error;

  String get _title => switch (widget.type) {
    TemplateType.bend => '单折弯展开',
    TemplateType.eccentricCone => '偏心圆锥台',
    TemplateType.elbow => '90°虾米腰弯头',
    TemplateType.tee => '圆管相贯',
    TemplateType.squareRound => widget.eccentric ? '单偏心天圆地方' : '同心天圆地方',
  };

  String get _asset => switch (widget.type) {
    TemplateType.bend || TemplateType.elbow => 'assets/components/elbow.png',
    TemplateType.eccentricCone => 'assets/components/conical_frustum.png',
    TemplateType.tee => 'assets/components/tee.png',
    TemplateType.squareRound => 'assets/components/square_round.png',
  };

  @override
  void initState() {
    super.initState();
    _specs = switch (widget.type) {
      TemplateType.bend => const [
        _GenericSpec('legA', '成形边长 A', 'mm', '300'),
        _GenericSpec('legB', '成形边长 B', 'mm', '200'),
        _GenericSpec('radius', '内弯半径 R', 'mm', '3'),
        _GenericSpec('thickness', '板厚 t', 'mm', '2'),
        _GenericSpec('angle', '折弯角度 θ', '°', '90'),
        _GenericSpec('kFactor', 'K 因子', '', '0.40'),
      ],
      TemplateType.eccentricCone => const [
        _GenericSpec('large', '大端直径 D', 'mm', '1000'),
        _GenericSpec('small', '小端直径 d', 'mm', '600'),
        _GenericSpec('height', '垂直高度 H', 'mm', '800'),
        _GenericSpec('offset', '偏心距 e', 'mm', '150'),
        _GenericSpec('segments', '圆周等分 n', '段', '12', integer: true),
      ],
      TemplateType.elbow => const [
        _GenericSpec('diameter', '管道直径 D', 'mm', '500'),
        _GenericSpec('radius', '中心弯曲半径 R', 'mm', '750'),
        _GenericSpec('angle', '弯头角度 θ', '°', '90'),
        _GenericSpec('pieces', '节数 n', '节', '4', integer: true),
      ],
      TemplateType.tee => const [
        _GenericSpec('mainDiameter', '主管直径 D', 'mm', '600'),
        _GenericSpec('branchDiameter', '支管直径 d', 'mm', '400'),
        _GenericSpec('angle', '轴线夹角 θ', '°', '90'),
        _GenericSpec('segments', '圆周等分 n', '段', '12', integer: true),
      ],
      TemplateType.squareRound => [
        const _GenericSpec('width', '方口宽度 A', 'mm', '800'),
        const _GenericSpec('depth', '方口深度 B', 'mm', '600'),
        const _GenericSpec('diameter', '圆口直径 D', 'mm', '500'),
        const _GenericSpec('height', '垂直高度 H', 'mm', '700'),
        _GenericSpec(
          'offsetX',
          '横向偏心 e₁',
          'mm',
          widget.eccentric ? '120' : '0',
          signed: true,
        ),
        const _GenericSpec('offsetY', '纵向偏心 e₂', 'mm', '0', signed: true),
        const _GenericSpec('segments', '周长等分 n', '段', '16', integer: true),
      ],
    };
    _controllers = _specs
        .map((item) => TextEditingController(text: item.example))
        .toList();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Map<String, double>? _values() {
    final values = <String, double>{};
    for (int i = 0; i < _specs.length; i++) {
      final value = double.tryParse(_controllers[i].text);
      if (value == null) return null;
      values[_specs[i].key] = value;
    }
    return values;
  }

  String? _validate(Map<String, double> value) {
    for (final entry in value.entries) {
      if (entry.key.startsWith('offset')) continue;
      if (entry.value <= 0) return '所有尺寸与角度必须大于 0';
    }
    return switch (widget.type) {
      TemplateType.bend =>
        value['angle']! >= 180
            ? '折弯角度必须小于 180°'
            : value['kFactor']! < 0 || value['kFactor']! > 1
            ? 'K 因子必须在 0–1 之间'
            : null,
      TemplateType.eccentricCone =>
        value['large']! <= value['small']!
            ? '大端直径必须大于小端直径'
            : value['offset']!.abs() > (value['large']! - value['small']!) / 2
            ? '偏心距过大，小端轮廓已超出大端'
            : _integerRange(value['segments']!, 8, 48, '等分数'),
      TemplateType.elbow =>
        value['radius']! < value['diameter']! / 2
            ? '中心弯曲半径不能小于管道半径'
            : value['angle']! >= 180
            ? '弯头角度必须小于 180°'
            : _integerRange(value['pieces']!, 2, 12, '节数'),
      TemplateType.tee =>
        value['branchDiameter']! > value['mainDiameter']!
            ? '支管直径不能大于主管直径'
            : value['angle']! <= 10 || value['angle']! >= 170
            ? '轴线夹角须在 10°–170° 之间'
            : _integerRange(value['segments']!, 8, 48, '等分数'),
      TemplateType.squareRound =>
        value['offsetX']!.abs() > (value['width']! + value['diameter']!) / 2 ||
                value['offsetY']!.abs() >
                    (value['depth']! + value['diameter']!) / 2
            ? '偏心距过大，两个端面投影无法形成有效过渡'
            : _integerRange(value['segments']!, 8, 48, '等分数'),
    };
  }

  String? _integerRange(double value, int minimum, int maximum, String name) {
    if (value != value.roundToDouble() || value < minimum || value > maximum) {
      return '$name须为 $minimum–$maximum 之间的整数';
    }
    return null;
  }

  Future<void> _calculate() async {
    FocusScope.of(context).unfocus();
    final values = _values();
    if (values == null) {
      setState(() => _error = '请完整填写所有参数');
      return;
    }
    final error = _validate(values);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    final result = switch (widget.type) {
      TemplateType.bend => EngineeringMath.bend(values),
      TemplateType.eccentricCone => EngineeringMath.eccentricCone(values),
      TemplateType.elbow => EngineeringMath.elbow(values),
      TemplateType.tee => EngineeringMath.tee(values),
      TemplateType.squareRound => EngineeringMath.squareRound(values),
    };
    setState(() => _error = null);
    await appStore.addEngineeringHistory(result);
    if (!mounted) return;
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => GenericResultPage(result: result),
      ),
    );
  }

  void _reset() {
    for (int i = 0; i < _specs.length; i++) {
      _controllers[i].text = _specs[i].example;
    }
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(CupertinoIcons.chevron_left),
        ),
        title: Text(
          _title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              builder: (_) => _GenericFormulaSheet(type: widget.type),
            ),
            icon: const Icon(CupertinoIcons.info_circle),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
                children: [
                  _GenericIllustration(
                    asset: _asset,
                    title: _title,
                    specs: _specs,
                    type: widget.type,
                  ),
                  const SizedBox(height: 10),
                  for (int i = 0; i < _specs.length; i++)
                    _ParameterRow(
                      label: _specs[i].label,
                      controller: _controllers[i],
                      unit: _specs[i].unit,
                      integer: _specs[i].integer,
                      signed: _specs[i].signed,
                      onChanged: (_) => setState(() => _error = null),
                    ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: Color(0xFFE54545),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      '内部计算保留完整精度，显示精度可在设置中调整。',
                      style: TextStyle(color: _muted, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: _line)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        for (final controller in _controllers) {
                          controller.clear();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text('清空'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _calculate,
                      style: FilledButton.styleFrom(
                        backgroundColor: _navy,
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text(
                        '计算',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reset,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text('示例'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenericIllustration extends StatelessWidget {
  const _GenericIllustration({
    required this.asset,
    required this.title,
    required this.specs,
    required this.type,
  });

  final String asset;
  final String title;
  final List<_GenericSpec> specs;
  final TemplateType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 235,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _line)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: type == TemplateType.bend
                ? const CustomPaint(
                    painter: _BendInputPainter(),
                    child: SizedBox.expand(),
                  )
                : Hero(
                    tag: 'calculator-$title',
                    child: Image.asset(asset, fit: BoxFit.contain),
                  ),
          ),
          const SizedBox(width: 15),
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final spec in specs.take(6))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      spec.label,
                      style: const TextStyle(fontSize: 12, color: _ink),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BendInputPainter extends CustomPainter {
  const _BendInputPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final steel = Paint()
      ..color = const Color(0xFFB9C2CB)
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final edge = Paint()
      ..color = _navy
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final dimension = Paint()
      ..color = _blue
      ..strokeWidth = 1.2;
    final path = Path()
      ..moveTo(size.width * .12, size.height * .74)
      ..lineTo(size.width * .52, size.height * .74)
      ..quadraticBezierTo(
        size.width * .66,
        size.height * .74,
        size.width * .66,
        size.height * .58,
      )
      ..lineTo(size.width * .66, size.height * .15);
    canvas
      ..drawPath(path, steel)
      ..drawPath(path, edge)
      ..drawLine(
        Offset(size.width * .12, size.height * .88),
        Offset(size.width * .58, size.height * .88),
        dimension,
      )
      ..drawLine(
        Offset(size.width * .82, size.height * .72),
        Offset(size.width * .82, size.height * .15),
        dimension,
      );
    _label(canvas, Offset(size.width * .31, size.height * .80), 'A');
    _label(canvas, Offset(size.width * .85, size.height * .40), 'B');
    _label(canvas, Offset(size.width * .51, size.height * .61), 'R');
    _label(canvas, Offset(size.width * .69, size.height * .62), 'θ');
  }

  void _label(Canvas canvas, Offset offset, String text) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: _blue,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GenericFormulaSheet extends StatelessWidget {
  const _GenericFormulaSheet({required this.type});

  final TemplateType type;

  @override
  Widget build(BuildContext context) {
    final text = switch (type) {
      TemplateType.bend => '采用 BA = πθ/180 × (R + Kt) 计算中性层折弯余量，再由外侧退让量求折弯扣除。',
      TemplateType.eccentricCone => '将大小端圆周对应等分点连接，使用三维距离公式逐点求各条素线实长。',
      TemplateType.elbow => '按等角虾米腰、两端半节模型划分转角，斜切口使用圆柱与斜平面相交的正弦曲线。',
      TemplateType.tee => '建立两个相交圆柱的解析方程，按支管圆周等分求每个相贯点高度。',
      TemplateType.squareRound => '将方口周长与圆口圆周等分，以三角形法逐点计算连接素线和近似侧面积。',
    };
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '计算模型',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            Text(text, style: const TextStyle(fontSize: 14, height: 1.6)),
            const SizedBox(height: 12),
            const Text(
              '结果不自动包含咬口、焊缝、折边、切割缝和材料回弹补偿。',
              style: TextStyle(color: Color(0xFFE54545), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class GenericResultPage extends StatefulWidget {
  const GenericResultPage({super.key, required this.result});

  final EngineeringResult result;

  @override
  State<GenericResultPage> createState() => _GenericResultPageState();
}

class _GenericResultPageState extends State<GenericResultPage> {
  bool _showPoints = true;

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final decimals = appStore.decimals;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(CupertinoIcons.chevron_left),
        ),
        title: const Text(
          '计算结果',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () => shareText(context, result.report(decimals)),
            icon: const Icon(CupertinoIcons.share),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
          children: [
            Row(
              children: [
                Text(
                  result.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  result.inputSummary,
                  style: const TextStyle(color: _muted, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: _line),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < result.metrics.length; i++)
                    Container(
                      height: 45,
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      decoration: BoxDecoration(
                        border: i == result.metrics.length - 1
                            ? null
                            : const Border(bottom: BorderSide(color: _line)),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Text(result.metrics[i].$1)),
                          Text(
                            result.metrics[i].$2.toStringAsFixed(
                              EngineeringResult._metricDecimals(
                                result.metrics[i].$3,
                                decimals,
                              ),
                            ),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          SizedBox(
                            width: 42,
                            child: Text(
                              result.metrics[i].$3,
                              textAlign: TextAlign.right,
                              style: const TextStyle(color: _muted),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 11),
            Row(
              children: [
                _ActionChip(
                  icon: CupertinoIcons.doc_on_doc,
                  label: '复制',
                  onTap: () async {
                    await Clipboard.setData(
                      ClipboardData(text: result.report(decimals)),
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('结果已复制')));
                  },
                ),
                const SizedBox(width: 8),
                _ActionChip(
                  icon: CupertinoIcons.share,
                  label: '分享',
                  onTap: () => shareText(context, result.report(decimals)),
                ),
                const SizedBox(width: 8),
                _ActionChip(
                  icon: CupertinoIcons.folder_badge_plus,
                  label: '存入项目',
                  onTap: () async {
                    await appStore.addEngineeringToProject(result);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已存入“现场计算”项目')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  '展开与点位',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                if (result.points.isNotEmpty)
                  CupertinoSwitch(
                    value: _showPoints,
                    onChanged: (value) => setState(() => _showPoints = value),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              height: 310,
              color: const Color(0xFFFAFBFC),
              child: CustomPaint(
                painter: _EngineeringPainter(
                  result: result,
                  showPoints: _showPoints,
                ),
                child: const SizedBox.expand(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              result.note,
              style: const TextStyle(color: _muted, fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 8),
            const Text(
              '不作为 1:1 打印模板，实际加工前请复核。',
              style: TextStyle(
                color: Color(0xFFE54545),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EngineeringPainter extends CustomPainter {
  const _EngineeringPainter({required this.result, required this.showPoints});

  final EngineeringResult result;
  final bool showPoints;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = _navy
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final helper = Paint()
      ..color = const Color(0xFF8EA0B5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final fill = Paint()
      ..color = const Color(0x140B68D1)
      ..style = PaintingStyle.fill;
    if (result.type == TemplateType.bend) {
      final path = Path()
        ..moveTo(size.width * .15, size.height * .72)
        ..lineTo(size.width * .48, size.height * .72)
        ..quadraticBezierTo(
          size.width * .60,
          size.height * .72,
          size.width * .60,
          size.height * .58,
        )
        ..lineTo(size.width * .60, size.height * .18);
      canvas.drawPath(path, line..strokeWidth = 8);
      canvas.drawLine(
        Offset(size.width * .13, size.height * .88),
        Offset(size.width * .87, size.height * .88),
        helper,
      );
      _paintLabel(
        canvas,
        Offset(size.width * .35, size.height * .80),
        '展开 L ${result.metrics.last.$2.toStringAsFixed(1)} mm',
      );
      return;
    }
    final values = result.points;
    if (values.isEmpty) return;
    final minimum = values.reduce(math.min);
    final maximum = values.reduce(math.max);
    final range = math.max(1, maximum - minimum);
    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = 24 + (size.width - 48) * i / (values.length - 1);
      final y =
          size.height - 45 - (size.height - 90) * (values[i] - minimum) / range;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      if (showPoints) {
        canvas.drawCircle(Offset(x, y), 3, Paint()..color = _blue);
        if (i % 2 == 0 || values.length <= 9) {
          _paintLabel(canvas, Offset(x - 4, y + 8), '${i + 1}', size: 9);
        }
      }
    }
    final area = Path.from(path)
      ..lineTo(size.width - 24, size.height - 32)
      ..lineTo(24, size.height - 32)
      ..close();
    canvas.drawPath(area, fill);
    canvas.drawPath(path, line);
    canvas.drawLine(
      Offset(24, size.height - 32),
      Offset(size.width - 24, size.height - 32),
      helper,
    );
    _paintLabel(
      canvas,
      const Offset(25, 18),
      '最大 ${maximum.toStringAsFixed(1)} mm',
    );
    _paintLabel(
      canvas,
      const Offset(25, 36),
      '最小 ${minimum.toStringAsFixed(1)} mm',
    );
  }

  void _paintLabel(
    Canvas canvas,
    Offset offset,
    String text, {
    double size = 11,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: _blue,
          fontSize: size,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _EngineeringPainter oldDelegate) =>
      result != oldDelegate.result || showPoints != oldDelegate.showPoints;
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  int _unit = 0;
  late final List<TextEditingController> _controllers;
  final labels = ['大端直径 A', '小端直径 B', '高度 H', '分段数 n'];
  final units = ['mm', 'mm', 'mm', '段'];
  String? _error;

  @override
  void initState() {
    super.initState();
    _controllers = [
      '1000',
      '600',
      '800',
      '12',
    ].map((value) => TextEditingController(text: value)).toList();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _setExample() {
    const values = ['1000', '600', '800', '12'];
    for (int i = 0; i < values.length; i++) {
      _controllers[i].text = values[i];
    }
    setState(() => _error = null);
  }

  void _clear() {
    for (final controller in _controllers) {
      controller.clear();
    }
    setState(() => _error = null);
  }

  void _changeUnit(int next) {
    if (_unit == next) return;
    const factors = [1.0, 10.0, 1000.0];
    for (int i = 0; i < 3; i++) {
      final value = double.tryParse(_controllers[i].text);
      if (value != null) {
        final mm = value * factors[_unit];
        _controllers[i].text = (mm / factors[next]).toStringAsFixed(
          next == 0
              ? 1
              : next == 1
              ? 2
              : 4,
        );
      }
    }
    setState(() {
      _unit = next;
      _error = null;
    });
  }

  Future<void> _calculate() async {
    FocusScope.of(context).unfocus();
    final parsed = _controllers
        .map((item) => double.tryParse(item.text))
        .toList();
    if (parsed.any((item) => item == null)) {
      setState(() => _error = '请完整填写所有参数');
      return;
    }
    const factors = [1.0, 10.0, 1000.0];
    final factor = factors[_unit];
    final large = parsed[0]! * factor;
    final small = parsed[1]! * factor;
    final height = parsed[2]! * factor;
    final segments = parsed[3]!.round();
    if (large <= 0 || small <= 0 || height <= 0) {
      setState(() => _error = '尺寸必须大于 0');
      return;
    }
    if (large <= small) {
      setState(() => _error = '大端直径必须大于小端直径');
      return;
    }
    if (segments < 6 || segments > 96 || parsed[3] != segments) {
      setState(() => _error = '分段数须为 6–96 之间的整数');
      return;
    }
    final result = ConeResult.calculate(
      largeDiameter: large,
      smallDiameter: small,
      height: height,
      thickness: 0,
      segments: segments,
    );
    setState(() => _error = null);
    await appStore.addHistory(result);
    if (!mounted) return;
    Navigator.of(context).push(
      CupertinoPageRoute<void>(builder: (_) => ResultPage(result: result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(CupertinoIcons.chevron_left, size: 23),
        ),
        title: const Text(
          '同心圆锥台',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          AnimatedBuilder(
            animation: appStore,
            builder: (context, _) => IconButton(
              tooltip: appStore.favorites.contains('同心圆锥台') ? '取消收藏' : '收藏',
              onPressed: () => appStore.toggleFavorite('同心圆锥台'),
              icon: Icon(
                appStore.favorites.contains('同心圆锥台')
                    ? CupertinoIcons.star_fill
                    : CupertinoIcons.star,
                color: appStore.favorites.contains('同心圆锥台')
                    ? const Color(0xFFFFB000)
                    : _ink,
                size: 22,
              ),
            ),
          ),
          IconButton(
            tooltip: '计算说明',
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              builder: (_) => const _FormulaSheet(),
            ),
            icon: const Icon(CupertinoIcons.info_circle, size: 22),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
                children: [
                  const _DimensionIllustration(),
                  const SizedBox(height: 18),
                  _UnitSwitch(selected: _unit, onSelect: _changeUnit),
                  const SizedBox(height: 10),
                  for (int i = 0; i < labels.length; i++)
                    _ParameterRow(
                      label: labels[i],
                      controller: _controllers[i],
                      unit: i < 3 ? ['mm', 'cm', 'm'][_unit] : units[i],
                      integer: i == 3,
                      onChanged: (_) => setState(() => _error = null),
                    ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.exclamationmark_circle_fill,
                            color: Color(0xFFE54545),
                            size: 16,
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: Color(0xFFE54545),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Padding(
                    padding: EdgeInsets.only(top: 9, left: 4),
                    child: Text(
                      '分段数越大，展开越精细，建议 12–24 段。',
                      style: TextStyle(color: _muted, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: _line)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clear,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _ink,
                        side: const BorderSide(color: _line),
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('清空'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _calculate,
                      style: FilledButton.styleFrom(
                        backgroundColor: _navy,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        '计算',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _setExample,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _ink,
                        side: const BorderSide(color: _line),
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('示例'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormulaSheet extends StatelessWidget {
  const _FormulaSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '同心圆锥台 · 计算说明',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            const Text(
              '按理想几何中性层计算。母线长度由高度与两端半径差求得，再由相似三角形得到展开扇形的内外半径和圆心角。',
              style: TextStyle(fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 12),
            Text(
              '适用条件：A ＞ B ＞ 0，分段数 6–96。结果不含咬口、焊缝、折边和切割余量。',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DimensionIllustration extends StatelessWidget {
  const _DimensionIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      padding: const EdgeInsets.fromLTRB(20, 10, 12, 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _line)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/components/conical_frustum.png',
                  fit: BoxFit.contain,
                ),
                const Positioned(
                  top: 18,
                  left: 28,
                  right: 28,
                  child: _MeasureLine(label: 'A'),
                ),
                const Positioned(
                  bottom: 12,
                  left: 6,
                  right: 6,
                  child: _MeasureLine(label: 'B'),
                ),
                const Positioned(
                  top: 58,
                  right: 0,
                  bottom: 38,
                  child: _VerticalMeasure(label: 'H'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Legend('A', '大端直径'),
                _Legend('B', '小端直径'),
                _Legend('H', '高度'),
                _Legend('n', '分段数'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MeasureLine extends StatelessWidget {
  const _MeasureLine({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _blue,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        Row(
          children: [
            const Icon(CupertinoIcons.chevron_left, size: 11, color: _blue),
            Expanded(child: Container(height: 1, color: _blue)),
            const Icon(CupertinoIcons.chevron_right, size: 11, color: _blue),
          ],
        ),
      ],
    );
  }
}

class _VerticalMeasure extends StatelessWidget {
  const _VerticalMeasure({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 1, color: _blue),
        const SizedBox(width: 5),
        Center(
          child: Text(
            label,
            style: const TextStyle(
              color: _blue,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend(this.symbol, this.label);

  final String symbol;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              symbol,
              style: const TextStyle(color: _blue, fontWeight: FontWeight.w700),
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 13, color: _ink)),
        ],
      ),
    );
  }
}

class _UnitSwitch extends StatelessWidget {
  const _UnitSwitch({required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          '单位',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const Spacer(),
        Container(
          height: 36,
          width: 210,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F2F5),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            children: [
              for (int i = 0; i < 3; i++)
                Expanded(
                  child: GestureDetector(
                    onTap: () => onSelect(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected == i ? _navy : Colors.transparent,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        ['mm', 'cm', 'm'][i],
                        style: TextStyle(
                          color: selected == i ? Colors.white : _ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ParameterRow extends StatelessWidget {
  const _ParameterRow({
    required this.label,
    required this.controller,
    required this.unit,
    required this.onChanged,
    this.integer = false,
    this.signed = false,
  });

  final String label;
  final TextEditingController controller;
  final String unit;
  final ValueChanged<String> onChanged;
  final bool integer;
  final bool signed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _line, width: .7)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            width: 142,
            height: 36,
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              keyboardType: TextInputType.numberWithOptions(decimal: !integer),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  integer
                      ? RegExp(r'[0-9]')
                      : signed
                      ? RegExp(r'[-0-9.]')
                      : RegExp(r'[0-9.]'),
                ),
              ],
              textInputAction: TextInputAction.next,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                filled: true,
                fillColor: _surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(color: _line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(color: _blue, width: 1.5),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 35,
            child: Text(
              unit,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, color: _muted),
            ),
          ),
        ],
      ),
    );
  }
}

class ResultPage extends StatefulWidget {
  const ResultPage({super.key, this.initialMode = 1, this.result});

  final int initialMode;
  final ConeResult? result;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late int _mode;
  late final ConeResult _result;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _result =
        widget.result ??
        ConeResult.calculate(
          largeDiameter: 1000,
          smallDiameter: 600,
          height: 800,
          thickness: 2,
          segments: 12,
        );
  }

  @override
  Widget build(BuildContext context) {
    final decimals = appStore.decimals;
    final results = [
      ('母线实长 L', _result.slant.toStringAsFixed(decimals), 'mm'),
      ('扇形内半径 R₁', _result.innerRadius.toStringAsFixed(decimals), 'mm'),
      ('扇形外半径 R₂', _result.outerRadius.toStringAsFixed(decimals), 'mm'),
      ('圆心角 θ', _result.angle.toStringAsFixed(decimals), '°'),
      ('理论下料面积 S', _result.area.toStringAsFixed(3), 'm²'),
      ('展开分段', _result.segments.toString(), '段'),
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(CupertinoIcons.chevron_left, size: 23),
        ),
        title: const Text(
          '计算结果',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: '分享结果',
            onPressed: () =>
                shareText(context, _result.report(appStore.decimals)),
            icon: const Icon(CupertinoIcons.share, size: 22),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
          children: [
            const Row(
              children: [
                Text(
                  '计算结果',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                SizedBox(width: 8),
                Text('同心圆锥台', style: TextStyle(color: _muted, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: _line),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < results.length; i++)
                    Container(
                      height: 43,
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      decoration: BoxDecoration(
                        border: i == results.length - 1
                            ? null
                            : const Border(
                                bottom: BorderSide(color: _line, width: .7),
                              ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              results[i].$1,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          Text(
                            results[i].$2,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            width: 38,
                            child: Text(
                              results[i].$3,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 11),
            Row(
              children: [
                _ActionChip(
                  icon: CupertinoIcons.doc_on_doc,
                  label: '复制结果',
                  onTap: () async {
                    await Clipboard.setData(
                      ClipboardData(text: _result.report(appStore.decimals)),
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('计算结果已复制')));
                  },
                ),
                const SizedBox(width: 8),
                _ActionChip(
                  icon: CupertinoIcons.share,
                  label: '分享',
                  onTap: () =>
                      shareText(context, _result.report(appStore.decimals)),
                ),
                const SizedBox(width: 8),
                _ActionChip(
                  icon: CupertinoIcons.folder_badge_plus,
                  label: '存入项目',
                  onTap: () async {
                    await appStore.addToProject(_result);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已存入“现场计算”项目')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 25),
            const Text(
              '展开图',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 11),
            Container(
              height: 38,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F5),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                children: [
                  for (int i = 0; i < 3; i++)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _mode = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _mode == i ? _navy : Colors.transparent,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            ['仅轮廓', '轮廓＋尺寸', '轮廓＋点位'][i],
                            style: TextStyle(
                              color: _mode == i ? Colors.white : _ink,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: SizedBox(
                key: ValueKey(_mode),
                height: 330,
                child: CustomPaint(
                  painter: _DevelopmentPainter(mode: _mode, result: _result),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            const Row(
              children: [
                Icon(
                  CupertinoIcons.exclamationmark_triangle,
                  color: Color(0xFFE54545),
                  size: 15,
                ),
                SizedBox(width: 6),
                Text(
                  '不作为 1:1 打印模板，请以实际放样为准。',
                  style: TextStyle(
                    color: Color(0xFFE54545),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                Icon(CupertinoIcons.fullscreen, color: _navy, size: 21),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: _line),
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 39,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: _navy, size: 17),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DevelopmentPainter extends CustomPainter {
  const _DevelopmentPainter({required this.mode, required this.result});

  final int mode;
  final ConeResult result;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .5, size.height * .14);
    final outerRadius = size.width * .46;
    final innerRadius =
        outerRadius * (result.innerRadius / result.outerRadius).clamp(.12, .78);
    const start = .17 * math.pi;
    final sweep = (result.angle * math.pi / 180).clamp(.5, math.pi * 1.65);
    final outline = Paint()
      ..color = _navy
      ..strokeWidth = 1.7
      ..style = PaintingStyle.stroke;
    final helper = Paint()
      ..color = const Color(0xFF8796A8)
      ..strokeWidth = .8
      ..style = PaintingStyle.stroke;
    final blue = Paint()
      ..color = _blue
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;

    final outer = Rect.fromCircle(center: center, radius: outerRadius);
    final inner = Rect.fromCircle(center: center, radius: innerRadius);
    canvas.drawArc(outer, start, sweep, false, outline);
    canvas.drawArc(inner, start, sweep, false, outline);

    final p1 = center + Offset(math.cos(start), math.sin(start)) * innerRadius;
    final p2 = center + Offset(math.cos(start), math.sin(start)) * outerRadius;
    final p3 =
        center +
        Offset(math.cos(start + sweep), math.sin(start + sweep)) * innerRadius;
    final p4 =
        center +
        Offset(math.cos(start + sweep), math.sin(start + sweep)) * outerRadius;
    canvas.drawLine(p1, p2, outline);
    canvas.drawLine(p3, p4, outline);

    if (mode > 0) {
      for (int i = 1; i < result.segments; i++) {
        final angle = start + sweep * i / result.segments;
        canvas.drawLine(
          center + Offset(math.cos(angle), math.sin(angle)) * innerRadius,
          center + Offset(math.cos(angle), math.sin(angle)) * outerRadius,
          helper,
        );
      }
      canvas.drawLine(center, p2, blue);
      _label(
        canvas,
        center + const Offset(38, 46),
        'R₂ ${result.outerRadius.toStringAsFixed(1)}',
      );
      _label(
        canvas,
        center + const Offset(-30, 84),
        'θ ${result.angle.toStringAsFixed(1)}°',
      );
      _label(
        canvas,
        Offset(size.width * .38, size.height * .92),
        'L ${result.slant.toStringAsFixed(1)} mm',
      );
    }

    if (mode == 2) {
      for (int i = 0; i <= result.segments; i++) {
        final angle = start + sweep * i / result.segments;
        final point =
            center + Offset(math.cos(angle), math.sin(angle)) * outerRadius;
        canvas.drawCircle(point, 3, Paint()..color = _blue);
        _label(canvas, point + const Offset(-3, 7), '${i + 1}', size: 9);
      }
    }
  }

  void _label(Canvas canvas, Offset at, String text, {double size = 11}) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: _blue,
          fontSize: size,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at);
  }

  @override
  bool shouldRepaint(covariant _DevelopmentPainter oldDelegate) =>
      mode != oldDelegate.mode || result != oldDelegate.result;
}

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appStore,
      builder: (context, _) => SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
              child: Row(
                children: [
                  const Text(
                    '项目',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${appStore.savedComponents.length + appStore.savedEngineering.length} 个构件',
                    style: const TextStyle(color: _muted, fontSize: 13),
                  ),
                ],
              ),
            ),
            Expanded(
              child:
                  appStore.savedComponents.isEmpty &&
                      appStore.savedEngineering.isEmpty
                  ? _EmptyState(
                      asset: 'assets/components/square_round.png',
                      title: '还没有项目构件',
                      detail: '计算完成后点“存入项目”，结果会离线保存在这里。',
                      action: '开始计算',
                      onTap: () => Navigator.of(context).push(
                        CupertinoPageRoute<void>(
                          builder: (_) => const CalculatorPage(),
                        ),
                      ),
                    )
                  : ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 90),
                      children: [
                        const Text(
                          '现场计算',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '仅保存在本机',
                          style: TextStyle(color: _muted, fontSize: 12),
                        ),
                        const SizedBox(height: 14),
                        for (final item in appStore.savedComponents)
                          _SavedResultRow(item: item),
                        for (final item in appStore.savedEngineering)
                          _SavedEngineeringRow(item: item),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedResultRow extends StatelessWidget {
  const _SavedResultRow({required this.item});

  final HistoryEntry item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        CupertinoPageRoute<void>(
          builder: (_) => ResultPage(result: item.result),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            SizedBox(
              width: 58,
              height: 58,
              child: Image.asset('assets/components/conical_frustum.png'),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.summary,
                    style: const TextStyle(color: _muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_right, size: 16, color: _muted),
          ],
        ),
      ),
    );
  }
}

class _SavedEngineeringRow extends StatelessWidget {
  const _SavedEngineeringRow({required this.item});

  final EngineeringEntry item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        CupertinoPageRoute<void>(
          builder: (_) => GenericResultPage(result: item.result),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            SizedBox(
              width: 58,
              height: 58,
              child: Image.asset(item.result.asset),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.result.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.result.inputSummary,
                    style: const TextStyle(color: _muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_right, size: 16, color: _muted),
          ],
        ),
      ),
    );
  }
}

// Legacy screenshot fixture kept for deterministic App Store scene rendering.
// ignore: unused_element
class _ProjectFilter extends StatelessWidget {
  const _ProjectFilter();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      height: 39,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          for (final label in ['全部', '我创建的', '共享给我'])
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: label == '全部' ? _navy : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: label == '全部' ? Colors.white : _ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _ProjectItem extends StatelessWidget {
  const _ProjectItem({
    required this.title,
    required this.client,
    required this.date,
    required this.count,
    required this.status,
    required this.statusColor,
    required this.tags,
  });

  final String title;
  final String client;
  final String date;
  final String count;
  final String status;
  final Color statusColor;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0B17324D),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    color: _ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '客户：$client',
            style: const TextStyle(color: _muted, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            '更新：$date    构件：$count',
            style: const TextStyle(color: _muted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            runSpacing: 6,
            children: [
              for (final tag in tags)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: Color(0xFF596779),
                      fontSize: 11,
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  CupertinoIcons.ellipsis,
                  size: 14,
                  color: _muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appStore,
      builder: (context, _) => SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 10, 8),
              child: Row(
                children: [
                  const Text(
                    '历史',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (appStore.history.isNotEmpty ||
                      appStore.engineeringHistory.isNotEmpty)
                    TextButton(
                      onPressed: () => showCupertinoDialog<void>(
                        context: context,
                        builder: (dialogContext) => CupertinoAlertDialog(
                          title: const Text('清空计算历史？'),
                          content: const Text('此操作无法撤销，项目中已保存的构件不会被删除。'),
                          actions: [
                            CupertinoDialogAction(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('取消'),
                            ),
                            CupertinoDialogAction(
                              isDestructiveAction: true,
                              onPressed: () {
                                appStore.clearHistory();
                                Navigator.pop(dialogContext);
                              },
                              child: const Text('清空'),
                            ),
                          ],
                        ),
                      ),
                      child: const Text('清空'),
                    ),
                ],
              ),
            ),
            Expanded(
              child:
                  appStore.history.isEmpty &&
                      appStore.engineeringHistory.isEmpty
                  ? _EmptyState(
                      asset: 'assets/components/conical_frustum.png',
                      title: '暂无计算记录',
                      detail: '每次有效计算都会自动保存在本机，最多保留 100 条。',
                      action: '开始计算',
                      onTap: () => Navigator.of(context).push(
                        CupertinoPageRoute<void>(
                          builder: (_) => const CalculatorPage(),
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 6, 18, 90),
                      itemCount:
                          appStore.engineeringHistory.length +
                          appStore.history.length,
                      itemBuilder: (context, index) {
                        if (index < appStore.engineeringHistory.length) {
                          final generic = appStore.engineeringHistory[index];
                          return Dismissible(
                            key: ValueKey(generic.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) =>
                                appStore.deleteEngineeringHistory(generic.id),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: const Color(0xFFE54545),
                              child: const Icon(
                                CupertinoIcons.delete,
                                color: Colors.white,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: SizedBox(
                                width: 48,
                                height: 48,
                                child: Image.asset(generic.result.asset),
                              ),
                              title: Text(
                                generic.result.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(generic.result.inputSummary),
                              trailing: Text(
                                _relativeTime(generic.createdAt),
                                style: const TextStyle(
                                  color: _muted,
                                  fontSize: 11,
                                ),
                              ),
                              onTap: () => Navigator.of(context).push(
                                CupertinoPageRoute<void>(
                                  builder: (_) =>
                                      GenericResultPage(result: generic.result),
                                ),
                              ),
                            ),
                          );
                        }
                        final item =
                            appStore.history[index -
                                appStore.engineeringHistory.length];
                        return Dismissible(
                          key: ValueKey(item.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => appStore.deleteHistory(item.id),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: const Color(0xFFE54545),
                            child: const Icon(
                              CupertinoIcons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: SizedBox(
                              width: 48,
                              height: 48,
                              child: Image.asset(
                                'assets/components/conical_frustum.png',
                              ),
                            ),
                            title: Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(item.summary),
                            trailing: Text(
                              _relativeTime(item.createdAt),
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 11,
                              ),
                            ),
                            onTap: () => Navigator.of(context).push(
                              CupertinoPageRoute<void>(
                                builder: (_) => ResultPage(result: item.result),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime value) {
    final difference = DateTime.now().difference(value);
    if (difference.inMinutes < 1) return '刚刚';
    if (difference.inHours < 1) return '${difference.inMinutes}分钟前';
    if (difference.inDays < 1) return '${difference.inHours}小时前';
    return '${value.month}月${value.day}日';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.asset,
    required this.title,
    required this.detail,
    required this.action,
    required this.onTap,
  });

  final String asset;
  final String title;
  final String detail;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 150, height: 130, child: Image.asset(asset)),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(backgroundColor: _navy),
              child: Text(action),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appStore,
      builder: (context, _) => SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 90),
          children: [
            const Text(
              '设置',
              style: TextStyle(
                color: _ink,
                fontSize: 27,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 23),
            const _SettingsLabel('计算'),
            _SettingsTile(
              title: '默认长度单位',
              value: '毫米（mm）',
              onTap: () => _showMessage(
                context,
                '长度单位',
                '计算页支持 mm、cm、m 即时切换，内部始终以毫米保留完整精度。',
              ),
            ),
            _SettingsTile(
              title: '结果小数位',
              value: ['整数', '0.1', '0.01'][appStore.decimals],
              onTap: () => showCupertinoModalPopup<void>(
                context: context,
                builder: (sheetContext) => CupertinoActionSheet(
                  title: const Text('结果小数位'),
                  actions: [
                    for (int i = 0; i < 3; i++)
                      CupertinoActionSheetAction(
                        onPressed: () {
                          appStore.setDecimals(i);
                          Navigator.pop(sheetContext);
                        },
                        child: Text(['整数', '0.1', '0.01'][i]),
                      ),
                  ],
                  cancelButton: CupertinoActionSheetAction(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: const Text('取消'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            const _SettingsLabel('数据与隐私'),
            _SettingsTile(
              title: '本机数据',
              value:
                  '${appStore.history.length + appStore.engineeringHistory.length} 条历史',
              onTap: () => _showMessage(
                context,
                '仅保存在本机',
                '本 App 无账号、无广告、无分析 SDK。参数、历史和项目不会上传到服务器。删除 App 会同时删除未导出的本机数据。',
              ),
            ),
            _SettingsTile(
              title: '分享数据说明',
              onTap: () => _showMessage(
                context,
                '用户主动分享',
                '只有在你点击“分享”后，结果文本才会交给 iOS 系统分享面板。App 不会在后台发送数据。',
              ),
            ),
            const SizedBox(height: 22),
            const _SettingsLabel('关于'),
            _SettingsTile(
              title: '公式与适用范围',
              onTap: () => showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                builder: (_) => const _FormulaSheet(),
              ),
            ),
            _SettingsTile(
              title: '使用与复核提示',
              onTap: () => _showMessage(
                context,
                '加工前必须复核',
                '结果基于用户输入和理想几何模型，用于辅助计算与放样。实际加工前请结合图纸、材料、板厚、咬口、焊缝、工艺余量和现场尺寸复核，必要时先制作试样。',
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 28),
              child: Text(
                '钣金展开 1.0.0 · 完全离线',
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String title, String content) {
    showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
}

class _SettingsLabel extends StatelessWidget {
  const _SettingsLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(3, 0, 3, 8),
      child: Text(
        text,
        style: const TextStyle(
          color: _muted,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    required this.onTap,
    this.value = '',
  });

  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: _line)),
        ),
        child: Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontSize: 14))),
            Text(value, style: const TextStyle(color: _muted, fontSize: 13)),
            const SizedBox(width: 7),
            const Icon(CupertinoIcons.chevron_right, size: 15, color: _muted),
          ],
        ),
      ),
    );
  }
}

// ignore: unused_element
class _SimplePage extends StatelessWidget {
  const _SimplePage({required this.title, required this.rows});

  final String title;
  final List<(String, String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const Icon(CupertinoIcons.search, size: 22),
              const SizedBox(width: 18),
              const Icon(CupertinoIcons.slider_horizontal_3, size: 22),
            ],
          ),
          const SizedBox(height: 23),
          for (final row in rows)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: _line)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      CupertinoIcons.arrow_up_left_arrow_down_right,
                      color: _blue,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row.$1,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          row.$2,
                          style: const TextStyle(color: _muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    row.$3,
                    style: const TextStyle(color: _muted, fontSize: 11),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.items});

  final String title;
  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 3, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: _muted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: _line),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++)
                Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    border: i == items.length - 1
                        ? null
                        : const Border(
                            bottom: BorderSide(color: _line, width: .7),
                          ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          items[i].$1,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        items[i].$2,
                        style: const TextStyle(color: _muted, fontSize: 13),
                      ),
                      const SizedBox(width: 7),
                      const Icon(
                        CupertinoIcons.chevron_right,
                        size: 15,
                        color: Color(0xFF9AA5B4),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
