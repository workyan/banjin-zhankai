// Generated from google-play/english-translations.json.
/// Compile with --dart-define=APP_LANGUAGE=en for the overseas variant.
/// The default Chinese build retains its current labels and data keys.
const useEnglish =
    String.fromEnvironment('APP_LANGUAGE', defaultValue: 'zh') == 'en';

abstract final class AppStrings {
  static const sheetMetalLayout = useEnglish ? 'Sheet Metal Layout' : '钣金展开';
  static const conicalFrustumResults = useEnglish
      ? 'Conical frustum results\n'
      : '同心圆锥台计算结果\n';
  static String largeDiameterAMm(Object? value0) =>
      useEnglish ? 'Large diameter A: $value0 mm\n' : '大端直径 A：$value0 mm\n';
  static String smallDiameterBMm(Object? value0) =>
      useEnglish ? 'Small diameter B: $value0 mm\n' : '小端直径 B：$value0 mm\n';
  static String heightHMm(Object? value0) =>
      useEnglish ? 'Height H: $value0 mm\n' : '高度 H：$value0 mm\n';
  static String slantLengthLMm(Object? value0) =>
      useEnglish ? 'Slant length L: $value0 mm\n' : '母线实长 L：$value0 mm\n';
  static String innerSectorRadiusRMm(Object? value0) => useEnglish
      ? 'Inner sector radius R₁: $value0 mm\n'
      : '扇形内半径 R₁：$value0 mm\n';
  static String outerSectorRadiusRMm(Object? value0) => useEnglish
      ? 'Outer sector radius R₂: $value0 mm\n'
      : '扇形外半径 R₂：$value0 mm\n';
  static String sectorAngle(Object? value0) =>
      useEnglish ? 'Sector angle θ: $value0°\n' : '圆心角 θ：$value0°\n';
  static String theoreticalAreaM(Object? value0) =>
      useEnglish ? 'Theoretical area: $value0 m²\n\n' : '理论下料面积：$value0 m²\n\n';
  static const resultsUseIdealGeometryCheckThicknessSeamsWeldsAndProcessAllowancesBef =
      useEnglish
      ? 'Results use ideal geometry. Check thickness, seams, welds and process allowances before fabrication.'
      : '结果基于理想几何模型，实际加工前请结合板厚、咬口、焊缝和工艺余量复核。';
  static String results(Object? value0, Object? value1) =>
      useEnglish ? '$value0 results\n$value1\n' : '$value0计算结果\n$value1\n';
  static const dividedPointTrueLengthsHeightsMm = useEnglish
      ? '\nDivided-point true lengths / heights (mm)'
      : '\n等分点实长/高度（mm）';
  static String checkThicknessSeamsAndProcessAllowancesBeforeFabrication(
    Object? value0,
  ) => useEnglish
      ? '\n$value0\nCheck thickness, seams and process allowances before fabrication.'
      : '\n$value0\n实际加工前请结合板厚、接缝与工艺余量复核。';
  static const segments = useEnglish ? 'div.' : '段';
  static const pieces = useEnglish ? 'pcs' : '节';
  static const singleBend = useEnglish ? 'Single bend' : '单折弯展开';
  static const bendAllowanceBA = useEnglish ? 'Bend allowance BA' : '折弯余量 BA';
  static const setbackSB = useEnglish ? 'Setback SB' : '单边退让 SB';
  static const bendDeductionBD = useEnglish ? 'Bend deduction BD' : '折弯扣除 BD';
  static const flatLengthL = useEnglish ? 'Flat length L' : '展开总长 L';
  static const usesTheNeutralAxisKFactorMethodAAndBAreTheFormedOutsideLegLengths =
      useEnglish
      ? 'Uses the neutral-axis K-factor method. A and B are the formed outside leg lengths.'
      : '按中性层 K 因子法计算，A、B 为成形后的外侧边长。';
  static const eccentricCone = useEnglish ? 'Eccentric cone' : '偏心圆锥台';
  static const shortestTrueLength = useEnglish
      ? 'Shortest true length'
      : '最短素线';
  static const longestTrueLength = useEnglish ? 'Longest true length' : '最长素线';
  static const meanTrueLength = useEnglish ? 'Mean true length' : '平均素线';
  static const theoreticalSideArea = useEnglish
      ? 'Theoretical side area'
      : '理论侧面积';
  static const usesTriangulatedTrueLengthsCircumferencePointsStartInTheOffsetDirectio =
      useEnglish
      ? 'Uses triangulated true lengths. Circumference points start in the offset direction.'
      : '采用对应母线三角形法，点位从偏心方向起按圆周等分。';
  static String segmentedElbow(Object? value0) =>
      useEnglish ? '$value0° segmented elbow' : '$value0°虾米腰弯头';
  static String dRPieces(Object? value0, Object? value1, Object? value2) =>
      useEnglish
      ? 'D $value0 · R $value1 · $value2 pieces'
      : 'D $value0 · R $value1 · $value2 节';
  static const developedWidth = useEnglish ? 'Developed width' : '圆周展开宽度';
  static const anglePerJoint = useEnglish ? 'Angle per joint' : '相邻节转角';
  static const miterAngle = useEnglish ? 'Miter angle' : '接口斜切角';
  static const centerPiecePitch = useEnglish ? 'Center-piece pitch' : '中心节轴向节距';
  static const cutHeightRange = useEnglish ? 'Cut height range' : '切口高差';
  static const usesEqualAngleSegmentsWithHalfPiecesAtBothEndsHeightsAreShownAt12Circu =
      useEnglish
      ? 'Uses equal-angle segments with half-pieces at both ends. Heights are shown at 12 circumference points.'
      : '按等角虾米腰、两端半节模型计算，点位为管周 12 等分切口高度。';
  static String pipeIntersection(Object? value0) =>
      useEnglish ? '$value0° pipe intersection' : '$value0°圆管相贯';
  static String mainBranch(Object? value0, Object? value1, Object? value2) =>
      useEnglish
      ? 'Main $value0 · Branch $value1 · $value2°'
      : '主管 $value0 · 支管 $value1 · $value2°';
  static const branchDevelopedWidth = useEnglish
      ? 'Branch developed width'
      : '支管展开宽度';
  static const maximumCutHeight = useEnglish ? 'Maximum cut height' : '相贯线最大高度';
  static const divisions = useEnglish ? 'Divisions' : '等分数';
  static const usesIntersectingCylinderGeometryPointsStartAtTheBranchCircumferenceRef =
      useEnglish
      ? 'Uses intersecting-cylinder geometry. Points start at the branch circumference reference.'
      : '按两圆柱轴线相交的解析模型计算，点位从支管圆周基准点开始。';
  static const centeredSquareToRound = useEnglish
      ? 'Centered square-to-round'
      : '同心天圆地方';
  static const offsetSquareToRound = useEnglish
      ? 'Offset square-to-round'
      : '偏心天圆地方';
  static const rectangularPerimeter = useEnglish
      ? 'Rectangular perimeter'
      : '方口周长';
  static const roundPerimeter = useEnglish ? 'Round perimeter' : '圆口周长';
  static const usesTriangulatedDivisionsOfBothPerimetersPointsRunClockwiseFromTheUppe =
      useEnglish
      ? 'Uses triangulated divisions of both perimeters. Points run clockwise from the upper-right reference.'
      : '按方口与圆口周长等分的三角形法计算，点位从方口右上方向顺时针编号。';
  static const conicalFrustum = useEnglish ? 'Conical frustum' : '同心圆锥台';
  static const dustDuctReducer = useEnglish ? 'Dust duct reducer' : '除尘管道变径节';
  static const layouts = useEnglish ? 'Layouts' : '展开';
  static const projects = useEnglish ? 'Projects' : '项目';
  static const history = useEnglish ? 'History' : '历史';
  static const settings = useEnglish ? 'Settings' : '设置';
  static const frustum = useEnglish ? 'Frustum' : '锥台';
  static const bends = useEnglish ? 'Bends' : '折弯';
  static const singleBendH0500de = useEnglish ? 'Single bend' : '单折弯';
  static const eccentricReducer = useEnglish ? 'Eccentric reducer' : '偏心大小头';
  static const elbows = useEnglish ? 'Elbows' : '弯头';
  static const label90Elbow = useEnglish ? '90° elbow' : '90°弯头';
  static const segmentedElbowH5a20f0 = useEnglish ? 'Segmented elbow' : '虾米腰';
  static const label90SegmentedElbow = useEnglish
      ? '90° segmented elbow'
      : '90°虾米腰弯头';
  static const tees = useEnglish ? 'Tees' : '三通';
  static const pipeTee = useEnglish ? 'Pipe tee' : '圆管三通';
  static const rightAngleTee = useEnglish ? 'Right-angle tee' : '三通正交';
  static const equalPipeTee = useEnglish ? 'Equal pipe tee' : '等径圆管三通';
  static const intersections = useEnglish ? 'Intersections' : '相贯';
  static const squareToRound = useEnglish ? 'Square-to-round' : '天圆地方';
  static const squareToRoundHa49e95 = useEnglish ? 'Square-to-round' : '方圆过渡';
  static const offsetTransition = useEnglish ? 'Offset transition' : '单偏心天圆地方';
  static const eccentric = useEnglish ? 'Eccentric' : '偏心';
  static const sharingIsUnavailableOnThisDevice = useEnglish
      ? 'Sharing is unavailable on this device.'
      : '当前设备没有可用的分享方式';
  static const tryAgain = useEnglish ? 'Try again.' : '请稍后重试';
  static String cannotOpenSharing(Object? value0) =>
      useEnglish ? 'Cannot open sharing: $value0' : '无法打开系统分享：$value0';
  static const cannotOpenSharingTryAgain = useEnglish
      ? 'Cannot open sharing. Try again.'
      : '无法打开系统分享，请稍后重试';
  static const recent = useEnglish ? 'Recent' : '最近使用';
  static const all = useEnglish ? 'All' : '全部';
  static const favorites = useEnglish ? 'Favorites' : '收藏';
  static const categories = useEnglish ? 'Categories' : '常用分类';
  static const searchShapes = useEnglish ? 'Search shapes' : '搜索构件、俗称';
  static const coneReducerFrustum = useEnglish
      ? 'cone reducer frustum'
      : '圆锥 大小头 锥台';
  static const eccentricReducerH79dc5c = useEnglish
      ? 'eccentric reducer'
      : '偏心 大小头';
  static const squareRoundTransition = useEnglish
      ? 'square round transition'
      : '方圆过渡 天方地圆';
  static const squareRoundOffsetTransition = useEnglish
      ? 'square round offset transition'
      : '方圆过渡 偏心';
  static const elbowPipeSegmentedMiter = useEnglish
      ? 'elbow pipe segmented miter'
      : '弯头 圆管 虾米腰';
  static const teeRightAngleIntersectionSaddle = useEnglish
      ? 'tee right angle intersection saddle'
      : '三通 正交 T型 相贯';
  static const bendFlatPatternKFactor = useEnglish
      ? 'bend flat pattern K factor'
      : '折弯 展开 K因子';
  static const noShapesFoundTryElbowOrReducer = useEnglish
      ? 'No shapes found. Try elbow or reducer.'
      : '没有找到构件，试试“弯头”或“大小头”';
  static const dimensionsDevelopmentPoints = useEnglish
      ? 'Dimensions · Development · Points'
      : '参数输入 · 展开数据 · 点位图';
  static const pipeIntersectionHe2b00c = useEnglish
      ? 'Pipe intersection'
      : '圆管相贯';
  static const outsideLegA = useEnglish ? 'Outside leg A' : '成形边长 A';
  static const outsideLegB = useEnglish ? 'Outside leg B' : '成形边长 B';
  static const insideRadiusR = useEnglish ? 'Inside radius R' : '内弯半径 R';
  static const thicknessT = useEnglish ? 'Thickness t' : '板厚 t';
  static const bendAngle = useEnglish ? 'Bend angle θ' : '折弯角度 θ';
  static const kFactor = useEnglish ? 'K factor' : 'K 因子';
  static const largeDiameterD = useEnglish ? 'Large diameter D' : '大端直径 D';
  static const smallDiameterD = useEnglish ? 'Small diameter d' : '小端直径 d';
  static const heightH = useEnglish ? 'Height H' : '垂直高度 H';
  static const offsetE = useEnglish ? 'Offset e' : '偏心距 e';
  static const divisionsN = useEnglish ? 'Divisions n' : '圆周等分 n';
  static const pipeDiameterD = useEnglish ? 'Pipe diameter D' : '管道直径 D';
  static const centerlineRadiusR = useEnglish
      ? 'Centerline radius R'
      : '中心弯曲半径 R';
  static const elbowAngle = useEnglish ? 'Elbow angle θ' : '弯头角度 θ';
  static const piecesN = useEnglish ? 'Pieces n' : '节数 n';
  static const mainDiameterD = useEnglish ? 'Main diameter D' : '主管直径 D';
  static const branchDiameterD = useEnglish ? 'Branch diameter d' : '支管直径 d';
  static const axisAngle = useEnglish ? 'Axis angle θ' : '轴线夹角 θ';
  static const rectangleWidthA = useEnglish ? 'Rectangle width A' : '方口宽度 A';
  static const rectangleDepthB = useEnglish ? 'Rectangle depth B' : '方口深度 B';
  static const roundDiameterD = useEnglish ? 'Round diameter D' : '圆口直径 D';
  static const offsetXE = useEnglish ? 'Offset X e₁' : '横向偏心 e₁';
  static const offsetYE = useEnglish ? 'Offset Y e₂' : '纵向偏心 e₂';
  static const perimeterDivisionsN = useEnglish
      ? 'Perimeter divisions n'
      : '周长等分 n';
  static const allDimensionsAndAnglesMustBePositive = useEnglish
      ? 'All dimensions and angles must be positive.'
      : '所有尺寸与角度必须大于 0';
  static const bendAngleMustBeLessThan180 = useEnglish
      ? 'Bend angle must be less than 180°.'
      : '折弯角度必须小于 180°';
  static const kFactorMustBeBetween0And1 = useEnglish
      ? 'K factor must be between 0 and 1.'
      : 'K 因子必须在 0–1 之间';
  static const largeDiameterMustExceedSmallDiameter = useEnglish
      ? 'Large diameter must exceed small diameter.'
      : '大端直径必须大于小端直径';
  static const offsetIsTooLargeTheSmallEndExtendsBeyondTheLargeEnd = useEnglish
      ? 'Offset is too large: the small end extends beyond the large end.'
      : '偏心距过大，小端轮廓已超出大端';
  static const centerlineRadiusCannotBeLessThanThePipeRadius = useEnglish
      ? 'Centerline radius cannot be less than the pipe radius.'
      : '中心弯曲半径不能小于管道半径';
  static const elbowAngleMustBeLessThan180 = useEnglish
      ? 'Elbow angle must be less than 180°.'
      : '弯头角度必须小于 180°';
  static const pieceCount = useEnglish ? 'Piece count' : '节数';
  static const branchDiameterCannotExceedMainDiameter = useEnglish
      ? 'Branch diameter cannot exceed main diameter.'
      : '支管直径不能大于主管直径';
  static const axisAngleMustBeBetween10And170 = useEnglish
      ? 'Axis angle must be between 10° and 170°.'
      : '轴线夹角须在 10°–170° 之间';
  static const offsetIsTooLargeToFormAValidTransition = useEnglish
      ? 'Offset is too large to form a valid transition.'
      : '偏心距过大，两个端面投影无法形成有效过渡';
  static String mustBeAWholeNumberFromTo(
    Object? value0,
    Object? value1,
    Object? value2,
  ) => useEnglish
      ? '$value0 must be a whole number from $value1 to $value2.'
      : '$value0须为 $value1–$value2 之间的整数';
  static const enterAllRequiredValues = useEnglish
      ? 'Enter all required values.'
      : '请完整填写所有参数';
  static const calculationsRetainFullPrecisionSetDisplayedDecimalPlacesInSettings =
      useEnglish
      ? 'Calculations retain full precision. Set displayed decimal places in Settings.'
      : '内部计算保留完整精度，显示精度可在设置中调整。';
  static const clear = useEnglish ? 'Clear' : '清空';
  static const calculate = useEnglish ? 'Calculate' : '计算';
  static const example = useEnglish ? 'Example' : '示例';
  static const bendAllowanceBA180RKtBendDeductionUsesTheOutsideSetbacks =
      useEnglish
      ? 'Bend allowance BA = πθ/180 × (R + Kt). Bend deduction uses the outside setbacks.'
      : '采用 BA = πθ/180 × (R + Kt) 计算中性层折弯余量，再由外侧退让量求折弯扣除。';
  static const connectCorrespondingCircumferencePointsAndUse3DDistancesToFindEachTrue =
      useEnglish
      ? 'Connect corresponding circumference points and use 3D distances to find each true length.'
      : '将大小端圆周对应等分点连接，使用三维距离公式逐点求各条素线实长。';
  static const equalAngleSegmentsAndHalfPiecesAtBothEndsDefineTheJointsMiterProfilesU =
      useEnglish
      ? 'Equal-angle segments and half-pieces at both ends define the joints. Miter profiles use cylinder-plane intersection curves.'
      : '按等角虾米腰、两端半节模型划分转角，斜切口使用圆柱与斜平面相交的正弦曲线。';
  static const intersectingCylinderEquationsGiveCutHeightsAtDividedBranchCircumferenc =
      useEnglish
      ? 'Intersecting-cylinder equations give cut heights at divided branch circumference points.'
      : '建立两个相交圆柱的解析方程，按支管圆周等分求每个相贯点高度。';
  static const triangulateDividedRectangularAndRoundPerimeterPointsForTrueLengthsAndA =
      useEnglish
      ? 'Triangulate divided rectangular and round perimeter points for true lengths and approximate side area.'
      : '将方口周长与圆口圆周等分，以三角形法逐点计算连接素线和近似侧面积。';
  static const calculationModel = useEnglish ? 'Calculation model' : '计算模型';
  static const resultsExcludeSeamWeldFlangeKerfAndSpringbackAllowances =
      useEnglish
      ? 'Results exclude seam, weld, flange, kerf and springback allowances.'
      : '结果不自动包含咬口、焊缝、折边、切割缝和材料回弹补偿。';
  static const resultsH45ba55 = useEnglish ? 'Results' : '计算结果';
  static const copy = useEnglish ? 'Copy' : '复制';
  static const resultCopied = useEnglish ? 'Result copied' : '结果已复制';
  static const share = useEnglish ? 'Share' : '分享';
  static const saveToProject = useEnglish ? 'Save to project' : '存入项目';
  static const savedToFieldCalculations = useEnglish
      ? 'Saved to Field calculations'
      : '已存入“现场计算”项目';
  static const developmentPoints = useEnglish
      ? 'Development & points'
      : '展开与点位';
  static const notA11CuttingTemplateVerifyBeforeFabrication = useEnglish
      ? 'Not a 1:1 cutting template. Verify before fabrication.'
      : '不作为 1:1 打印模板，实际加工前请复核。';
  static String flatLMm(Object? value0) =>
      useEnglish ? 'Flat L $value0 mm' : '展开 L $value0 mm';
  static String maxMm(Object? value0) =>
      useEnglish ? 'Max $value0 mm' : '最大 $value0 mm';
  static String minMm(Object? value0) =>
      useEnglish ? 'Min $value0 mm' : '最小 $value0 mm';
  static const largeDiameterA = useEnglish ? 'Large diameter A' : '大端直径 A';
  static const smallDiameterB = useEnglish ? 'Small diameter B' : '小端直径 B';
  static const heightHHb1964e = useEnglish ? 'Height H' : '高度 H';
  static const divisionsNHeadad9 = useEnglish ? 'Divisions n' : '分段数 n';
  static const dimensionsMustBePositive = useEnglish
      ? 'Dimensions must be positive.'
      : '尺寸必须大于 0';
  static const divisionsMustBeAWholeNumberFrom6To96 = useEnglish
      ? 'Divisions must be a whole number from 6 to 96.'
      : '分段数须为 6–96 之间的整数';
  static const removeFavorite = useEnglish ? 'Remove favorite' : '取消收藏';
  static const calculationNotes = useEnglish ? 'Calculation notes' : '计算说明';
  static const moreDivisionsGiveAFinerLayoutTypicallyUse1224 = useEnglish
      ? 'More divisions give a finer layout. Typically use 12–24.'
      : '分段数越大，展开越精细，建议 12–24 段。';
  static const conicalFrustumNotes = useEnglish
      ? 'Conical frustum · Notes'
      : '同心圆锥台 · 计算说明';
  static const usesIdealNeutralSurfaceGeometryHeightAndRadiusDifferenceGiveTheSlantLe =
      useEnglish
      ? 'Uses ideal neutral-surface geometry. Height and radius difference give the slant length; similar triangles give sector radii and angle.'
      : '按理想几何中性层计算。母线长度由高度与两端半径差求得，再由相似三角形得到展开扇形的内外半径和圆心角。';
  static const requiresAB0And696DivisionsResultsExcludeSeamsWeldsFlangesAndCuttingAll =
      useEnglish
      ? 'Requires A > B > 0 and 6–96 divisions. Results exclude seams, welds, flanges and cutting allowances.'
      : '适用条件：A ＞ B ＞ 0，分段数 6–96。结果不含咬口、焊缝、折边和切割余量。';
  static const largeDiameter = useEnglish ? 'Large diameter' : '大端直径';
  static const smallDiameter = useEnglish ? 'Small diameter' : '小端直径';
  static const height = useEnglish ? 'Height' : '高度';
  static const divisionsH7c6534 = useEnglish ? 'Divisions' : '分段数';
  static const unit = useEnglish ? 'Unit' : '单位';
  static const slantLengthL = useEnglish ? 'Slant length L' : '母线实长 L';
  static const innerRadiusR = useEnglish ? 'Inner radius R₁' : '扇形内半径 R₁';
  static const outerRadiusR = useEnglish ? 'Outer radius R₂' : '扇形外半径 R₂';
  static const sectorAngleHdd1ffb = useEnglish ? 'Sector angle θ' : '圆心角 θ';
  static const theoreticalAreaS = useEnglish
      ? 'Theoretical area S'
      : '理论下料面积 S';
  static const layoutDivisions = useEnglish ? 'Layout divisions' : '展开分段';
  static const shareResult = useEnglish ? 'Share result' : '分享结果';
  static const copyResult = useEnglish ? 'Copy result' : '复制结果';
  static const calculationCopied = useEnglish
      ? 'Calculation copied'
      : '计算结果已复制';
  static const flatPattern = useEnglish ? 'Flat pattern' : '展开图';
  static const outline = useEnglish ? 'Outline' : '仅轮廓';
  static const dimensions = useEnglish ? 'Dimensions' : '轮廓＋尺寸';
  static const points = useEnglish ? 'Points' : '轮廓＋点位';
  static const notA11TemplateUseVerifiedLayoutDimensions = useEnglish
      ? 'Not a 1:1 template. Use verified layout dimensions.'
      : '不作为 1:1 打印模板，请以实际放样为准。';
  static String components(Object? value0) =>
      useEnglish ? '$value0 components' : '$value0 个构件';
  static const noSavedComponents = useEnglish
      ? 'No saved components'
      : '还没有项目构件';
  static const chooseSaveToProjectAfterCalculatingResultsStayOnThisDevice =
      useEnglish
      ? 'Choose Save to project after calculating. Results stay on this device.'
      : '计算完成后点“存入项目”，结果会离线保存在这里。';
  static const startCalculating = useEnglish ? 'Start calculating' : '开始计算';
  static const fieldCalculations = useEnglish ? 'Field calculations' : '现场计算';
  static const onThisDeviceOnly = useEnglish ? 'On this device only' : '仅保存在本机';
  static const myProjects = useEnglish ? 'My projects' : '我创建的';
  static const sharedWithMe = useEnglish ? 'Shared with me' : '共享给我';
  static String client(Object? value0) =>
      useEnglish ? 'Client: $value0' : '客户：$value0';
  static String updatedComponents(Object? value0, Object? value1) => useEnglish
      ? 'Updated: $value0 · Components: $value1'
      : '更新：$value0    构件：$value1';
  static const clearCalculationHistory = useEnglish
      ? 'Clear calculation history?'
      : '清空计算历史？';
  static const thisCannotBeUndoneComponentsSavedToProjectsWillRemain =
      useEnglish
      ? 'This cannot be undone. Components saved to projects will remain.'
      : '此操作无法撤销，项目中已保存的构件不会被删除。';
  static const cancel = useEnglish ? 'Cancel' : '取消';
  static const noCalculationsYet = useEnglish
      ? 'No calculations yet'
      : '暂无计算记录';
  static const completedCalculationsAreSavedOnThisDeviceUpTo100Entries =
      useEnglish
      ? 'Completed calculations are saved on this device, up to 100 entries.'
      : '每次有效计算都会自动保存在本机，最多保留 100 条。';
  static const justNow = useEnglish ? 'Just now' : '刚刚';
  static String minAgo(Object? value0) =>
      useEnglish ? '$value0 min ago' : '$value0分钟前';
  static String hoursAgo(Object? value0) =>
      useEnglish ? '$value0 hours ago' : '$value0小时前';
  static String label(Object? value0, Object? value1) =>
      useEnglish ? '$value0/$value1' : '$value0月$value1日';
  static const defaultLengthUnit = useEnglish
      ? 'Default length unit'
      : '默认长度单位';
  static const millimetresMm = useEnglish ? 'Millimetres (mm)' : '毫米（mm）';
  static const lengthUnits = useEnglish ? 'Length units' : '长度单位';
  static const switchBetweenMmCmAndMInternalCalculationsRetainFullPrecisionInMillimet =
      useEnglish
      ? 'Switch between mm, cm and m. Internal calculations retain full precision in millimetres.'
      : '计算页支持 mm、cm、m 即时切换，内部始终以毫米保留完整精度。';
  static const decimalPlaces = useEnglish ? 'Decimal places' : '结果小数位';
  static const wholeNumbers = useEnglish ? 'Whole numbers' : '整数';
  static const dataPrivacy = useEnglish ? 'Data & privacy' : '数据与隐私';
  static const localData = useEnglish ? 'Local data' : '本机数据';
  static String historyEntries(Object? value0) =>
      useEnglish ? '$value0 history entries' : '$value0 条历史';
  static const noAccountsAdsOrAnalyticsSDKsInputsHistoryAndProjectsAreNotUploadedUnin =
      useEnglish
      ? 'No accounts, ads or analytics SDKs. Inputs, history and projects are not uploaded. Uninstalling removes app-local data.'
      : '本 App 无账号、无广告、无分析 SDK。参数、历史和项目不会上传到服务器。删除 App 会同时删除未导出的本机数据。';
  static const sharing = useEnglish ? 'Sharing' : '分享数据说明';
  static const onlyWhenYouChoose = useEnglish
      ? 'Only when you choose'
      : '用户主动分享';
  static const resultTextIsPassedToTheSystemShareSheetOnlyWhenYouChooseShareTheAppDoe =
      useEnglish
      ? 'Result text is passed to the system share sheet only when you choose Share. The app does not send it in the background.'
      : '只有在你点击“分享”后，结果文本才会交给 iOS 系统分享面板。App 不会在后台发送数据。';
  static const about = useEnglish ? 'About' : '关于';
  static const formulasAndScope = useEnglish ? 'Formulas and scope' : '公式与适用范围';
  static const reviewChecklist = useEnglish ? 'Review checklist' : '使用与复核提示';
  static const verifyBeforeFabrication = useEnglish
      ? 'Verify before fabrication'
      : '加工前必须复核';
  static const resultsUseYourInputsAndIdealGeometryCheckDrawingsMaterialsThicknessSea =
      useEnglish
      ? 'Results use your inputs and ideal geometry. Check drawings, materials, thickness, seams, welds, process allowances and site measurements before fabrication. Make a test piece when needed.'
      : '结果基于用户输入和理想几何模型，用于辅助计算与放样。实际加工前请结合图纸、材料、板厚、咬口、焊缝、工艺余量和现场尺寸复核，必要时先制作试样。';
  static const sheetMetalLayout100Offline = useEnglish
      ? 'Sheet Metal Layout 1.0.0 · Offline'
      : '钣金展开 1.0.0 · 完全离线';
  static const ok = useEnglish ? 'OK' : '知道了';
}
