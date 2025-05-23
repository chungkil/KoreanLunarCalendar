import Foundation

/// 한국 음력 날짜와 양력 날짜 간의 변환을 처리하는 클래스입니다.
public class KoreanLunarCalendar {
    // MARK: - Properties
    private var lunarYear: Int = 0
    private var lunarMonth: Int = 0
    private var lunarDay: Int = 0
    private var isIntercalation: Bool = false

    private var solarYear: Int = 0
    private var solarMonth: Int = 0
    private var solarDay: Int = 0

    private var gapjaYearInx: [Int] = [0, 0, 0]
    private var gapjaMonthInx: [Int] = [0, 0, 1]
    private var gapjaDayInx: [Int] = [0, 0, 2]

    // MARK: - Constants
    private static let KOREAN_LUNAR_MIN_VALUE: Int = 10000101
    private static let KOREAN_LUNAR_MAX_VALUE: Int = 20501118
    private static let KOREAN_SOLAR_MIN_VALUE: Int = 10000213
    private static let KOREAN_SOLAR_MAX_VALUE: Int = 20501231

    private static let KOREAN_LUNAR_BASE_YEAR: Int = 1000
    private static let SOLAR_LUNAR_DAY_DIFF: Int = 43

    private static let LUNAR_SMALL_MONTH_DAY: Int = 29
    private static let LUNAR_BIG_MONTH_DAY: Int = 30
    private static let SOLAR_SMALL_YEAR_DAY: Int = 365
    private static let SOLAR_BIG_YEAR_DAY: Int = 366

    private static let SOLAR_DAYS: [Int] = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 29]
    
    private static let KOREAN_CHEONGAN: [Character] = ["갑", "을", "병", "정", "무", "기", "경", "신", "임", "계"]
    private static let KOREAN_GANJI: [Character] = ["자", "축", "인", "묘", "진", "사", "오", "미", "신", "유", "술", "해"]
    private static let KOREAN_GAPJA_UNIT: [Character] = ["년", "월", "일"]

    private static let CHINESE_CHEONGAN: [Character] = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"]
    private static let CHINESE_GANJI: [Character] = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]
    private static let CHINESE_GAPJA_UNIT: [Character] = ["年", "月", "日"]

    private static let INTERCALATION_STR: [Character] = ["윤", "閏"]

    // 음력 데이터 (1000년부터 2050년까지)
    private static let KOREAN_LUNAR_DATA: [Int] = [
        0x82c60a57, 0x82fec52b, 0x82c40d2a, 0x82c60d55, 0xc30095ad, 0x82c4056a, 0x82c6096d, 0x830054dd, 0xc2c404ad, 0x82c40a4d,
        0x83002e4d, 0x82c40b26, 0xc300ab56, 0x82c60ad5, 0x82c4035a, 0x8300697a, 0xc2c6095b, 0x82c4049b, 0x83004a9b, 0x82c40a4b,
        0xc301caa5, 0x82c406aa, 0x82c60ad5, 0x830092dd, 0xc2c402b5, 0x82c60957, 0x82fe54ae, 0x82c60c97, 0xc2c4064b, 0x82ff254a,
        0x82c60da9, 0x8300a6b6, 0xc2c6066d, 0x82c4026e, 0x8301692e, 0x82c4092e, 0xc2c40c96, 0x83004d95, 0x82c40d4a, 0x8300cd69,
        0xc2c40b58, 0x82c80d6b, 0x8301926b, 0x82c4025d, 0xc2c4092b, 0x83005aab, 0x82c40a95, 0x82c40b4a, 0xc3021eab, 0x82c402d5,
		0x8301b55a, 0x82c604bb, 0xc2c4025b, 0x83007537, 0x82c4052b, 0x82c40695, 0xc3003755, 0x82c406aa, 0x8303cab5, 0x82c40275,
		0xc2c404b6, 0x83008a5e, 0x82c40a56, 0x82c40d26, 0xc3005ea6, 0x82c60d55, 0x82c405aa, 0x83001d6a, 0xc2c6096d, 0x8300b4af,
		0x82c4049d, 0x82c40a4d, 0xc3007d2d, 0x82c40aa6, 0x82c60b55, 0x830045d5, 0xc2c4035a, 0x82c6095d, 0x83011173, 0x82c4045b,
		0xc3009a4f, 0x82c4064b, 0x82c40aa5, 0x83006b69, 0xc2c606b5, 0x82c402da, 0x83002ab6, 0x82c60937, 0xc2fec497, 0x82c60c97,
		0x82c4064b, 0x82fe86aa, 0xc2c60da5, 0x82c405b4, 0x83034a6d, 0x82c402ae, 0xc2c40e61, 0x83002d2e, 0x82c40c96, 0x83009d4d,
		0x82c40d4a, 0x82c60d65, 0x83016595, 0x82c6055d, 0xc2c4026d, 0x83002a5d, 0x82c4092b, 0x8300aa97, 0xc2c40a95, 0x82c40b4a,
		0x83008b5a, 0x82c60ad5, 0xc2c6055b, 0x830042b7, 0x82c40457, 0x82c4052b, 0xc3001d2b, 0x82c40695, 0x8300972d, 0x82c405aa,
		0xc2c60ab5, 0x830054ed, 0x82c404b6, 0x82c60a57, 0xc2ff344e, 0x82c40d26, 0x8301be92, 0x82c60d55, 0xc2c405aa, 0x830089ba,
		0x82c6096d, 0x82c404ae, 0xc3004a9d, 0x82c40a4d, 0x82c40d25, 0x83002f25, 0xc2c40b54, 0x8303ad69, 0x82c402da, 0x82c6095d,
		0xc301649b, 0x82c4049b, 0x82c40a4b, 0x83004b4b, 0xc2c406a5, 0x8300bb53, 0x82c406b4, 0x82c60ab6, 0xc3018956, 0x82c60997,
		0x82c40497, 0x83004697, 0xc2c4054b, 0x82fec6a5, 0x82c60da5, 0x82c405ac, 0xc303aab5, 0x82c4026e, 0x82c4092e, 0x83006cae,
		0xc2c40c96, 0x82c40d4a, 0x83002f4a, 0x82c60d55, 0xc300b56b, 0x82c6055b, 0x82c4025d, 0x8300793d, 0xc2c40927, 0x82c40a95,
		0x83015d15, 0x82c40b4a, 0xc2c60b55, 0x830112d5, 0x82c604db, 0x82fe925e, 0xc2c60a57, 0x82c4052b, 0x83006aab, 0x82c40695,
		0xc2c406aa, 0x83003baa, 0x82c60ab5, 0x8300b4b7, 0xc2c404ae, 0x82c60a57, 0x82fe752e, 0x82c40d26, 0xc2c60e93, 0x830056d5,
		0x82c405aa, 0x82c609b5, 0xc300256d, 0x82c404ae, 0x8301aa4d, 0x82c40a4d, 0xc2c40d26, 0x83006d65, 0x82c40b52, 0x82c60d6a,
		0xc30026da, 0x82c6095d, 0x8301c49d, 0x82c4049b, 0xc2c40a4b, 0x83008aab, 0x82c406a5, 0x82c40b54, 0xc3004bb4, 0x82c60ab6,
		0x82c6095b, 0x83002537, 0xc2c40497, 0x8300964f, 0x82c4054b, 0x82c406a5, 0xc30176c5, 0x82c405ac, 0x82c60ab6, 0x8301386e,
		0xc2c4092e, 0x8300cc97, 0x82c40c96, 0x82c40d4a, 0xc3008daa, 0x82c60b55, 0x82c4056a, 0x83025adb, 0xc2c4025d, 0x82c4092e,
		0x83002d2b, 0x82c40a95, 0xc3009d4d, 0x82c40b2a, 0x82c60b55, 0x83007575, 0xc2c404da, 0x82c60a5b, 0x83004557, 0x82c4052b,
		0xc301ca93, 0x82c40693, 0x82c406aa, 0x83008ada, 0xc2c60ae5, 0x82c404b6, 0x83004aae, 0x82c60a57, 0xc2c40527, 0x82ff2526,
		0x82c60e53, 0x8300a6cb, 0xc2c405aa, 0x82c605ad, 0x830164ad, 0x82c404ae, 0xc2c40a4e, 0x83004d4d, 0x82c40d26, 0x8300bd53,
		0xc2c40b52, 0x82c60b6a, 0x8301956a, 0x82c60557, 0xc2c4049d, 0x83015a1b, 0x82c40a4b, 0x82c40aa5, 0xc3001ea5, 0x82c40b52,
		0x8300bb5a, 0x82c60ab6, 0xc2c6095b, 0x830064b7, 0x82c40497, 0x82c4064b, 0xc300374b, 0x82c406a5, 0x8300b6b3, 0x82c405ac,
		0xc2c60ab6, 0x830182ad, 0x82c4049e, 0x82c40a4d, 0xc3005d4b, 0x82c40b25, 0x82c40b52, 0x83012e52, 0xc2c60b5a, 0x8300a95e,
		0x82c6095b, 0x82c4049b, 0xc3006a57, 0x82c40a4b, 0x82c40aa5, 0x83004ba5, 0xc2c406d4, 0x8300cad6, 0x82c60ab6, 0x82c60937,
		0x8300849f, 0x82c40497, 0x82c4064b, 0x82fe56ca, 0xc2c60da5, 0x82c405aa, 0x83001d6c, 0x82c60a6e, 0xc300b92f, 0x82c4092e,
		0x82c40c96, 0x83007d55, 0xc2c40d4a, 0x82c60d55, 0x83013555, 0x82c4056a, 0xc2c60a6d, 0x83001a5d, 0x82c4092b, 0x83008a5b,
		0xc2c40a95, 0x82c40b2a, 0x83015b2a, 0x82c60ad5, 0xc2c404da, 0x83001cba, 0x82c60a57, 0x8300952f, 0xc2c40527, 0x82c40693,
		0x830076b3, 0x82c406aa, 0xc2c60ab5, 0x83003575, 0x82c404b6, 0x8300ca67, 0xc2c40a2e, 0x82c40d16, 0x83008e96, 0x82c40d4a,
		0xc2c60daa, 0x830055ea, 0x82c6056d, 0x82c404ae, 0xc301285d, 0x82c40a2d, 0x8300ad17, 0x82c40aa5, 0xc2c40b52, 0x83007d74,
		0x82c60ada, 0x82c6055d, 0xc300353b, 0x82c4045b, 0x82c40a2b, 0x83011a2b, 0xc2c40aa5, 0x83009b55, 0x82c406b2, 0x82c60ad6,
		0xc3015536, 0x82c60937, 0x82c40457, 0x83003a57, 0xc2c4052b, 0x82feaaa6, 0x82c60d95, 0x82c405aa, 0xc3017aac, 0x82c60a6e,
		0x82c4052e, 0x83003cae, 0xc2c40a56, 0x8300bd2b, 0x82c40d2a, 0x82c60d55, 0xc30095ad, 0x82c4056a, 0x82c60a6d, 0x8300555d,
		0xc2c4052b, 0x82c40a8d, 0x83002e55, 0x82c40b2a, 0xc300ab56, 0x82c60ad5, 0x82c404da, 0x83006a7a, 0xc2c60a57, 0x82c4051b,
		0x83014a17, 0x82c40653, 0xc301c6a9, 0x82c405aa, 0x82c60ab5, 0x830092bd, 0xc2c402b6, 0x82c60a37, 0x82fe552e, 0x82c40d16,
		0x82c60e4b, 0x82fe3752, 0x82c60daa, 0x8301b5b4, 0xc2c6056d, 0x82c402ae, 0x83007a3d, 0x82c40a2d, 0xc2c40d15, 0x83004d95,
		0x82c40b52, 0x8300cb69, 0xc2c60ada, 0x82c6055d, 0x8301925b, 0x82c4045b, 0xc2c40a2b, 0x83005aab, 0x82c40a95, 0x82c40b52,
		0xc3001eaa, 0x82c60ab6, 0x8300c55b, 0x82c604b7, 0xc2c40457, 0x83007537, 0x82c4052b, 0x82c40695, 0xc3014695, 0x82c405aa,
		0x8300cab5, 0x82c60a6e, 0xc2c404ae, 0x83008a5e, 0x82c40a56, 0x82c40d2a, 0xc3006eaa, 0x82c60d55, 0x82c4056a, 0x8301295a,
		0xc2c6095d, 0x8300b4af, 0x82c4049b, 0x82c40a4d, 0xc3007d2d, 0x82c40b2a, 0x82c60b55, 0x830045d5, 0xc2c402da, 0x82c6095b,
		0x83011157, 0x82c4049b, 0xc3009a4f, 0x82c4064b, 0x82c406a9, 0x83006aea, 0xc2c606b5, 0x82c402b6, 0x83002aae, 0x82c60937,
		0xc2ffb496, 0x82c40c96, 0x82c60e4b, 0x82fe76b2, 0xc2c60daa, 0x82c605ad, 0x8300336d, 0x82c4026e, 0xc2c4092e, 0x83002d2d,
		0x82c40c95, 0x83009d4d, 0xc2c40b4a, 0x82c60b69, 0x8301655a, 0x82c6055b, 0xc2c4025d, 0x83002a5b, 0x82c4092b, 0x8300aa97,
		0xc2c40695, 0x82c4074a, 0x83008b5a, 0x82c60ab6, 0xc2c6053b, 0x830042b7, 0x82c40257, 0x82c4052b, 0xc3001d2b, 0x82c40695,
		0x830096ad, 0x82c405aa, 0xc2c60ab5, 0x830054ed, 0x82c404ae, 0x82c60a57, 0xc2ff344e, 0x82c40d2a, 0x8301bd94, 0x82c60b55,
		0x82c4056a, 0x8300797a, 0x82c6095d, 0x82c404ae, 0xc3004a9b, 0x82c40a4d, 0x82c40d25, 0x83011aaa, 0xc2c60b55, 0x8300956d,
		0x82c402da, 0x82c6095b, 0xc30054b7, 0x82c40497, 0x82c40a4b, 0x83004b4b, 0xc2c406a9, 0x8300cad5, 0x82c605b5, 0x82c402b6,
		0xc300895e, 0x82c6092f, 0x82c40497, 0x82fe4696, 0xc2c40d4a, 0x8300cea5, 0x82c60d69, 0x82c6056d, 0xc301a2b5, 0x82c4026e,
		0x82c4092e, 0x83006cad, 0xc2c40c95, 0x82c40d4a, 0x83002f4a, 0x82c60b59, 0xc300c56d, 0x82c6055b, 0x82c4025d, 0x8300793b,
		0xc2c4092b, 0x82c40a95, 0x83015b15, 0x82c406ca, 0xc2c60ad5, 0x830112b6, 0x82c604bb, 0x8300925f, 0xc2c40257, 0x82c4052b,
		0x82fe6aaa, 0x82c60e95, 0xc2c406aa, 0x83003baa, 0x82c60ab5, 0x8300b4b7, 0xc2c404ae, 0x82c60a57, 0x82fe752d, 0x82c40d26,
		0xc2c60d95, 0x830055d5, 0x82c4056a, 0x82c6096d, 0xc300255d, 0x82c404ae, 0x8300aa4f, 0x82c40a4d, 0xc2c40d25, 0x83006d69,
		0x82c60b55, 0x82c4035a, 0xc3002aba, 0x82c6095b, 0x8301c49b, 0x82c40497, 0xc2c40a4b, 0x83008b2b, 0x82c406a5, 0x82c406d4,
		0xc3034ab5, 0x82c402b6, 0x82c60937, 0x8300252f, 0xc2c40497, 0x82fe964e, 0x82c40d4a, 0x82c60ea5, 0xc30166a9, 0x82c6056d,
		0x82c402b6, 0x8301385e, 0xc2c4092e, 0x8300bc97, 0x82c40a95, 0x82c40d4a, 0xc3008daa, 0x82c60b4d, 0x82c6056b, 0x830042db,
		0xc2c4025d, 0x82c4092d, 0x83002d2b, 0x82c40a95, 0xc3009b4d, 0x82c406aa, 0x82c60ad5, 0x83006575, 0xc2c604bb, 0x82c4025b,
		0x83013457, 0x82c4052b, 0xc2ffba94, 0x82c60e95, 0x82c406aa, 0x83008ada, 0xc2c609b5, 0x82c404b6, 0x83004aae, 0x82c60a4f,
		0xc2c20526, 0x83012d26, 0x82c60d55, 0x8301a5a9, 0xc2c4056a, 0x82c6096d, 0x8301649d, 0x82c4049e, 0xc2c40a4d, 0x83004d4d,
		0x82c40d25, 0x8300bd53, 0xc2c40b54, 0x82c60b5a, 0x8301895a, 0x82c6095b, 0xc2c4049b, 0x83004a97, 0x82c40a4b, 0x82c40aa5,
		0xc3001ea5, 0x82c406d4, 0x8302badb, 0x82c402b6, 0xc2c60937, 0x830064af, 0x82c40497, 0x82c4064b, 0xc2fe374a, 0x82c60da5,
		0x8300b6b5, 0x82c6056d, 0xc2c402ae, 0x8300793e, 0x82c4092e, 0x82c40c96, 0xc3015d15, 0x82c40d4a, 0x82c60da5, 0x83013555,
		0xc2c4056a, 0x83007a7a, 0x82c60a5d, 0x82c4092d, 0xc3006aab, 0x82c40a95, 0x82c40b4a, 0x83004baa, 0xc2c60ad5, 0x82c4055a,
		0x830128ba, 0x82c60a5b, 0xc3007537, 0x82c4052b, 0x82c40693, 0x83015715, 0xc2c406aa, 0x82c60ad5, 0x830035b5, 0x82c404b6,
		0xc3008a5e, 0x82c40a4e, 0x82c40d26, 0x83006ea6, 0xc2c40d52, 0x82c60daa, 0x8301466a, 0x82c6056d, 0xc2c404ae, 0x83003a9d,
		0x82c40a4d, 0x83007d2b, 0xc2c40b25, 0x82c40d52, 0x83015d54, 0x82c60b5a, 0xc2c6055d, 0x8300355b, 0x82c4049b, 0x83007657,
		0x82c40a4b, 0x82c40aa5, 0x83006b65, 0x82c406d2, 0xc2c60ada, 0x830045b6, 0x82c60937, 0x82c40497, 0xc3003697, 0x82c4064d,
		0x82fe76aa, 0x82c60da5, 0xc2c405aa, 0x83005aec, 0x82c60aae, 0x82c4092e, 0xc3003d2e, 0x82c40c96, 0x83018d45, 0x82c40d4a,
		0xc2c60d55, 0x83016595, 0x82c4056a, 0x82c60a6d, 0xc300455d, 0x82c4052d, 0x82c40a95, 0x83013c95, 0xc2c40b4a, 0x83017b4a,
		0x82c60ad5, 0x82c4055a, 0xc3015a3a, 0x82c60a5b, 0x82c4052b, 0x83014a17, 0xc2c40693, 0x830096ab, 0x82c406aa, 0x82c60ab5,
		0xc30064f5, 0x82c404b6, 0x82c60a57, 0x82fe452e, 0xc2c40d16, 0x82c60e93, 0x82fe3752, 0x82c60daa, 0xc30175aa, 0x82c6056d,
		0x82c404ae, 0x83015a1d, 0xc2c40a2d, 0x82c40d15, 0x83004da5, 0x82c40b52, 0xc3009d6a, 0x82c60ada, 0x82c6055d, 0x8301629b,
		0xc2c4045b, 0x82c40a2b, 0x83005b2b, 0x82c40a95, 0xc2c40b52, 0x83012ab2, 0x82c60ad6, 0x83017556, 0xc2c60537, 0x82c40457,
		0x83005657, 0x82c4052b, 0xc2c40695, 0x83003795, 0x82c405aa, 0x8300aab6, 0xc2c60a6d, 0x82c404ae, 0x83006a6e, 0x82c40a56,
		0xc2c40d2a, 0x83005eaa, 0x82c60d55, 0x82c405aa, 0xc3003b6a, 0x82c60a6d, 0x830074bd, 0x82c404ab, 0xc2c40a8d, 0x83005d55,
		0x82c40b2a, 0x82c60b55, 0xc30045d5, 0x82c404da, 0x82c6095d, 0x83002557, 0xc2c4049b, 0x83006a97, 0x82c4064b, 0x82c406a9,
		0x83004baa, 0x82c606b5, 0x82c402ba, 0x83002ab6, 0xc2c60937, 0x82fe652e, 0x82c40d16, 0x82c60e4b, 0xc2fe56d2, 0x82c60da9,
		0x82c605b5, 0x8300336d, 0xc2c402ae, 0x82c40a2e, 0x83002e2d, 0x82c40c95, 0xc3006d55, 0x82c40b52, 0x82c60b69, 0x830045da,
		0xc2c6055d, 0x82c4025d, 0x83003a5b, 0x82c40a2b, 0xc3017a8b, 0x82c40a95, 0x82c40b4a, 0x83015b2a, 0xc2c60ad5, 0x82c6055b,
		0x830042b7, 0x82c40257, 0xc300952f, 0x82c4052b, 0x82c40695, 0x830066d5, 0xc2c405aa, 0x82c60ab5, 0x8300456d, 0x82c404ae,
		0xc2c60a57, 0x82ff3456, 0x82c40d2a, 0x83017e8a, 0xc2c60d55, 0x82c405aa, 0x83005ada, 0x82c6095d, 0xc2c404ae, 0x83004aab,
		0x82c40a4d, 0x83008d2b, 0xc2c40b29, 0x82c60b55, 0x83007575, 0x82c402da, 0xc2c6095d, 0x830054d7, 0x82c4049b, 0x82c40a4b,
		0xc3013a4b, 0x82c406a9, 0x83008ad9, 0x82c606b5, 0xc2c402b6, 0x83015936, 0x82c60937, 0x82c40497, 0xc2fe4696, 0x82c40e4a,
		0x8300aea6, 0x82c60da9, 0xc2c605ad, 0x830162ad, 0x82c402ae, 0x82c4092e, 0xc3005cad, 0x82c40c95, 0x82c40d4a, 0x83013d4a,
		0xc2c60b69, 0x8300757a, 0x82c6055b, 0x82c4025d, 0xc300595b, 0x82c4092b, 0x82c40a95, 0x83004d95, 0xc2c40b4a, 0x82c60b55,
		0x830026d5, 0x82c6055b, 0xc3006277, 0x82c40257, 0x82c4052b, 0x82fe5aaa, 0xc2c60e95, 0x82c406aa, 0x83003baa, 0x82c60ab5,
		0x830084bd, 0x82c404ae, 0x82c60a57, 0x82fe554d, 0xc2c40d26, 0x82c60d95, 0x83014655, 0x82c4056a, 0xc2c609ad, 0x8300255d,
		0x82c404ae, 0x83006a5b, 0xc2c40a4d, 0x82c40d25, 0x83005da9, 0x82c60b55, 0xc2c4056a, 0x83002ada, 0x82c6095d, 0x830074bb,
		0xc2c4049b, 0x82c40a4b, 0x83005b4b, 0x82c406a9, 0xc2c40ad4, 0x83024bb5, 0x82c402b6, 0x82c6095b, 0xc3002537, 0x82c40497,
		0x82fe6656, 0x82c40e4a, 0xc2c60ea5, 0x830156a9, 0x82c605b5, 0x82c402b6, 0xc30138ae, 0x82c4092e, 0x83017c8d, 0x82c40c95,
		0xc2c40d4a, 0x83016d8a, 0x82c60b69, 0x82c6056d, 0xc301425b, 0x82c4025d, 0x82c4092d, 0x83002d2b, 0xc2c40a95, 0x83007d55,
		0x82c40b4a, 0x82c60b55, 0xc3015555, 0x82c604db, 0x82c4025b, 0x83013857, 0xc2c4052b, 0x83008a9b, 0x82c40695, 0x82c406aa,
		0xc3006aea, 0x82c60ab5, 0x82c404b6, 0x83004aae, 0xc2c60a57, 0x82c40527, 0x82fe3726, 0x82c60d95, 0xc30076b5, 0x82c4056a,
		0x82c609ad, 0x830054dd, 0xc2c404ae, 0x82c40a4e, 0x83004d4d, 0x82c40d25, 0xc3008d59, 0x82c40b54, 0x82c60d6a, 0x8301695a,
		0xc2c6095b, 0x82c4049b, 0x83004a9b, 0x82c40a4b, 0xc300ab27, 0x82c406a5, 0x82c406d4, 0x83026b75, 0xc2c402b6, 0x82c6095b,
		0x830054b7, 0x82c40497, 0xc2c4064b, 0x82fe374a, 0x82c60ea5, 0x830086d9, 0xc2c605ad, 0x82c402b6, 0x8300596e, 0x82c4092e,
		0xc2c40c96, 0x83004e95, 0x82c40d4a, 0x82c60da5, 0xc3002755, 0x82c4056c, 0x83027abb, 0x82c4025d, 0xc2c4092d, 0x83005cab,
		0x82c40a95, 0x82c40b4a, 0xc3013b4a, 0x82c60b55, 0x8300955d, 0x82c404ba, 0xc2c60a5b, 0x83005557, 0x82c4052b, 0x82c40a95,
		0xc3004b95, 0x82c406aa, 0x82c60ad5, 0x830026b5, 0xc2c404b6, 0x83006a6e, 0x82c60a57, 0x82c40527, 0xc2fe56a6, 0x82c60d93,
		0x82c405aa, 0x83003b6a, 0xc2c6096d, 0x8300b4af, 0x82c404ae, 0x82c40a4d, 0xc3016d0d, 0x82c40d25, 0x82c40d52, 0x83005dd4,
		0xc2c60b6a, 0x82c6096d, 0x8300255b, 0x82c4049b, 0xc3007a57, 0x82c40a4b, 0x82c40b25, 0x83015b25, 0xc2c406d4, 0x82c60ada,
		0x830138b6
			]

    
    init() {}
    
    // MARK: - Helper Methods
    private func getLunarData(year: Int) -> Int {
        return KoreanLunarCalendar.KOREAN_LUNAR_DATA[year - KoreanLunarCalendar.KOREAN_LUNAR_BASE_YEAR]
    }
    
    private func getLunarIntercalationMonth(lunarData: Int) -> Int {
        return (lunarData >> 12) & 0x000F
    }
    
    private func getLunarDays(year: Int) -> Int {
        let lunarData = getLunarData(year: year)
        return (lunarData >> 17) & 0x01FF
    }
    
    private func getLunarDays(year: Int, month: Int, isIntercalation: Bool) -> Int {
        var days = 0
        let lunarData = getLunarData(year: year)
        
        if isIntercalation && getLunarIntercalationMonth(lunarData: lunarData) == month {
            days = ((lunarData >> 16) & 0x01) > 0 ? KoreanLunarCalendar.LUNAR_BIG_MONTH_DAY : KoreanLunarCalendar.LUNAR_SMALL_MONTH_DAY
        } else {
            days = ((lunarData >> (12 - month)) & 0x01) > 0 ? KoreanLunarCalendar.LUNAR_BIG_MONTH_DAY : KoreanLunarCalendar.LUNAR_SMALL_MONTH_DAY
        }
        
        return days
    }
    
    private func getLunarDaysBeforeBaseYear(year: Int) -> Int {
        var days = 0
        for baseYear in KoreanLunarCalendar.KOREAN_LUNAR_BASE_YEAR..<(year + 1) {
            days += getLunarDays(year: baseYear)
        }
        return days
    }
    
    private func getLunarDaysBeforeBaseMonth(year: Int, month: Int, isIntercalation: Bool) -> Int {
        var days = 0
        
        if year >= KoreanLunarCalendar.KOREAN_LUNAR_BASE_YEAR && month > 0 {
            for baseMonth in 1..<(month + 1) {
                days += getLunarDays(year: year, month: baseMonth, isIntercalation: false)
            }
            
            if isIntercalation {
                let intercalationMonth = getLunarIntercalationMonth(lunarData: getLunarData(year: year))
                if intercalationMonth > 0 && intercalationMonth < month + 1 {
                    days += getLunarDays(year: year, month: intercalationMonth, isIntercalation: true)
                }
            }
        }
        
        return days
    }
    
    private func getLunarAbsDays(year: Int, month: Int, day: Int, isIntercalation: Bool) -> Int {
        var days = 0
        days = getLunarDaysBeforeBaseYear(year: year - 1) + getLunarDaysBeforeBaseMonth(year: year, month: month - 1, isIntercalation: true) + day
        
        if isIntercalation && getLunarIntercalationMonth(lunarData: getLunarData(year: year)) == month {
            days += getLunarDays(year: year, month: month, isIntercalation: false)
        }
        
        return days
    }
    
    private func isSolarIntercalationYear(lunarData: Int) -> Bool {
        return ((lunarData >> 30) & 0x01) > 0
    }
    
    private func getSolarDays(year: Int) -> Int {
        let lunarData = getLunarData(year: year)
        return isSolarIntercalationYear(lunarData: lunarData) ? KoreanLunarCalendar.SOLAR_BIG_YEAR_DAY : KoreanLunarCalendar.SOLAR_SMALL_YEAR_DAY
    }
    
    private func getSolarDays(year: Int, month: Int) -> Int {
        let lunarData = getLunarData(year: year)
        
        if month == 2 && isSolarIntercalationYear(lunarData: lunarData) {
            return KoreanLunarCalendar.SOLAR_DAYS[12]
        } else {
            return KoreanLunarCalendar.SOLAR_DAYS[month - 1]
        }
    }
    
    private func getSolarDayBeforeBaseYear(year: Int) -> Int {
        var days = 0
        for baseYear in KoreanLunarCalendar.KOREAN_LUNAR_BASE_YEAR..<(year + 1) {
            days += getSolarDays(year: baseYear)
        }
        return days
    }
    
    private func getSolarDaysBeforeBaseMonth(year: Int, month: Int) -> Int {
        var days = 0
        for baseMonth in 1..<(month + 1) {
            days += getSolarDays(year: year, month: baseMonth)
        }
        return days
    }
    
    private func getSolarAbsDays(year: Int, month: Int, day: Int) -> Int {
        var days = 0
        days = getSolarDayBeforeBaseYear(year: year - 1) + getSolarDaysBeforeBaseMonth(year: year, month: month - 1) + day
        days -= KoreanLunarCalendar.SOLAR_LUNAR_DAY_DIFF
        return days
    }
    
    private func setSolarDateByLunarDate(lunarYear: Int, lunarMonth: Int, lunarDay: Int, isIntercalation: Bool) {
        let absDays = getLunarAbsDays(year: lunarYear, month: lunarMonth, day: lunarDay, isIntercalation: isIntercalation)
        var solarYear = 0
        var solarMonth = 0
        var solarDay = 0
        
        solarYear = (absDays < getSolarAbsDays(year: lunarYear + 1, month: 1, day: 1)) ? lunarYear : lunarYear + 1
        
        for month in (1...12).reversed() {
            let absDaysByMonth = getSolarAbsDays(year: solarYear, month: month, day: 1)
            if absDays >= absDaysByMonth {
                solarMonth = month
                solarDay = absDays - absDaysByMonth + 1
                break
            }
        }
        
        setSolarYear(solarYear)
        setSolarMonth(solarMonth)
        setSolarDay(solarDay)
    }
    
    private func setLunarDateBySolarDate(solarYear: Int, solarMonth: Int, solarDay: Int) {
        let absDays = getSolarAbsDays(year: solarYear, month: solarMonth, day: solarDay)
        var lunarYear = 0
        var lunarMonth = 0
        var lunarDay = 0
        var isIntercalation = false
        
        lunarYear = (absDays >= getLunarAbsDays(year: solarYear, month: 1, day: 1, isIntercalation: false)) ? solarYear : solarYear - 1
        
        for month in (1...12).reversed() {
            let absDaysByMonth = getLunarAbsDays(year: lunarYear, month: month, day: 1, isIntercalation: false)
            if absDays >= absDaysByMonth {
                lunarMonth = month
                
                if getLunarIntercalationMonth(lunarData: getLunarData(year: lunarYear)) == month {
                    isIntercalation = absDays >= getLunarAbsDays(year: lunarYear, month: month, day: 1, isIntercalation: true)
                }
                
                lunarDay = absDays - getLunarAbsDays(year: lunarYear, month: lunarMonth, day: 1, isIntercalation: isIntercalation) + 1
                break
            }
        }
        
        setLunarYear(lunarYear)
        setLunarMonth(lunarMonth)
        setLunarDay(lunarDay)
        setIntercalation(isIntercalation)
    }
    
    private func checkValidDate(isLunar: Bool, isIntercalation: Bool, year: Int, month: Int, day: Int) -> Bool {
        var isValid = false
        let dateValue = year * 10000 + month * 100 + day
        
        // 1582. 10. 5 ~ 1582. 10. 14 is not enable
        if ((isLunar ? KoreanLunarCalendar.KOREAN_LUNAR_MIN_VALUE : KoreanLunarCalendar.KOREAN_SOLAR_MIN_VALUE) <= dateValue
            && (isLunar ? KoreanLunarCalendar.KOREAN_LUNAR_MAX_VALUE : KoreanLunarCalendar.KOREAN_SOLAR_MAX_VALUE) >= dateValue) {
            if month > 0 && month < 13 && day > 0 {
                var dayLimit = isLunar ? getLunarDays(year: year, month: month, isIntercalation: isIntercalation) : getSolarDays(year: year, month: month)
                if !isLunar && year == 1582 && month == 10 {
                    if day > 4 && day < 15 {
                        return false
                    } else {
                        dayLimit += 10
                    }
                }
                if day <= dayLimit {
                    isValid = true
                }
            }
        }
        return isValid
    }
    
    // MARK: - Public Methods
    
    /// 음력 날짜를 설정합니다.
    ///
    /// - Parameters:
    ///   - lunarYear: 음력 연도
    ///   - lunarMonth: 음력 월
    ///   - lunarDay: 음력 일
    ///   - isIntercalation: 윤달 여부
    /// - Returns: 유효한 날짜인 경우 true, 그렇지 않으면 false
    public func setLunarDate(lunarYear: Int, lunarMonth: Int, lunarDay: Int, isIntercalation: Bool) -> Bool {
        var isValid = false
        if checkValidDate(isLunar: true, isIntercalation: isIntercalation, year: lunarYear, month: lunarMonth, day: lunarDay) {
            setLunarYear(lunarYear)
            setLunarMonth(lunarMonth)
            setLunarDay(lunarDay)
            setIntercalation(isIntercalation && (getLunarIntercalationMonth(lunarData: getLunarData(year: lunarYear)) == lunarMonth))
            setSolarDateByLunarDate(lunarYear: lunarYear, lunarMonth: lunarMonth, lunarDay: lunarDay, isIntercalation: isIntercalation)
            isValid = true
        }
        return isValid
    }
    
    /// 양력 날짜를 설정합니다.
    ///
    /// - Parameters:
    ///   - solarYear: 양력 연도
    ///   - solarMonth: 양력 월
    ///   - solarDay: 양력 일
    /// - Returns: 유효한 날짜인 경우 true, 그렇지 않으면 false
    public func setSolarDate(solarYear: Int, solarMonth: Int, solarDay: Int) -> Bool {
        var isValid = false
        if checkValidDate(isLunar: false, isIntercalation: false, year: solarYear, month: solarMonth, day: solarDay) {
            setSolarYear(solarYear)
            setSolarMonth(solarMonth)
            setSolarDay(solarDay)
            setLunarDateBySolarDate(solarYear: solarYear, solarMonth: solarMonth, solarDay: solarDay)
            isValid = true
        }
        return isValid
    }
    
    private func getGapJa() {
        let absDays = getLunarAbsDays(year: lunarYear, month: lunarMonth, day: lunarDay, isIntercalation: isIntercalation)
        if absDays > 0 {
            gapjaYearInx[0] = ((lunarYear + 6) - KoreanLunarCalendar.KOREAN_LUNAR_BASE_YEAR) % KoreanLunarCalendar.KOREAN_CHEONGAN.count
            gapjaYearInx[1] = ((lunarYear + 0) - KoreanLunarCalendar.KOREAN_LUNAR_BASE_YEAR) % KoreanLunarCalendar.KOREAN_GANJI.count
            
            var monthCount = self.lunarMonth
            monthCount += 12 * (lunarYear - KoreanLunarCalendar.KOREAN_LUNAR_BASE_YEAR)
            gapjaMonthInx[0] = (monthCount + 3) % KoreanLunarCalendar.KOREAN_CHEONGAN.count
            gapjaMonthInx[1] = (monthCount + 1) % KoreanLunarCalendar.KOREAN_GANJI.count
            
            gapjaDayInx[0] = (absDays + 4) % KoreanLunarCalendar.KOREAN_CHEONGAN.count
            gapjaDayInx[1] = (absDays + 2) % KoreanLunarCalendar.KOREAN_GANJI.count
        }
    }
    
    /// 한국어 갑자 문자열을 반환합니다.
    public func getGapjaString() -> String {
        getGapJa()
        
        var gapjaString = ""
        gapjaString.append(KoreanLunarCalendar.KOREAN_CHEONGAN[gapjaYearInx[0]])
        gapjaString.append(KoreanLunarCalendar.KOREAN_GANJI[gapjaYearInx[1]])
        gapjaString.append(KoreanLunarCalendar.KOREAN_GAPJA_UNIT[gapjaYearInx[2]])
        gapjaString.append(" ")
        gapjaString.append(KoreanLunarCalendar.KOREAN_CHEONGAN[gapjaMonthInx[0]])
        gapjaString.append(KoreanLunarCalendar.KOREAN_GANJI[gapjaMonthInx[1]])
        gapjaString.append(KoreanLunarCalendar.KOREAN_GAPJA_UNIT[gapjaMonthInx[2]])
        gapjaString.append(" ")
        gapjaString.append(KoreanLunarCalendar.KOREAN_CHEONGAN[gapjaDayInx[0]])
        gapjaString.append(KoreanLunarCalendar.KOREAN_GANJI[gapjaDayInx[1]])
        gapjaString.append(KoreanLunarCalendar.KOREAN_GAPJA_UNIT[gapjaDayInx[2]])
        
        if getIntercalation() {
            gapjaString.append(" (")
            gapjaString.append(KoreanLunarCalendar.INTERCALATION_STR[0])
            gapjaString.append(KoreanLunarCalendar.KOREAN_GAPJA_UNIT[1])
            gapjaString.append(")")
        }
        return gapjaString
    }
    
    /// 중국어 갑자 문자열을 반환합니다.
    public func getChineseGapJaString() -> String {
        getGapJa()
        
        var gapjaString = ""
        gapjaString.append(KoreanLunarCalendar.CHINESE_CHEONGAN[gapjaYearInx[0]])
        gapjaString.append(KoreanLunarCalendar.CHINESE_GANJI[gapjaYearInx[1]])
        gapjaString.append(KoreanLunarCalendar.CHINESE_GAPJA_UNIT[gapjaYearInx[2]])
        gapjaString.append(" ")
        gapjaString.append(KoreanLunarCalendar.CHINESE_CHEONGAN[gapjaMonthInx[0]])
        gapjaString.append(KoreanLunarCalendar.CHINESE_GANJI[gapjaMonthInx[1]])
        gapjaString.append(KoreanLunarCalendar.CHINESE_GAPJA_UNIT[gapjaMonthInx[2]])
        gapjaString.append(" ")
        gapjaString.append(KoreanLunarCalendar.CHINESE_CHEONGAN[gapjaDayInx[0]])
        gapjaString.append(KoreanLunarCalendar.CHINESE_GANJI[gapjaDayInx[1]])
        gapjaString.append(KoreanLunarCalendar.CHINESE_GAPJA_UNIT[gapjaDayInx[2]])
        
        if getIntercalation() {
            gapjaString.append(" (")
            gapjaString.append(KoreanLunarCalendar.INTERCALATION_STR[1])
            gapjaString.append(KoreanLunarCalendar.CHINESE_GAPJA_UNIT[1])
            gapjaString.append(")")
        }
        return gapjaString
    }
    
    /// 음력 날짜의 ISO 형식 문자열을 반환합니다.
    public func getLunarIsoFormat() -> String {
        var isoStr = String(format: "%04d-%02d-%02d", lunarYear, lunarMonth, lunarDay)
        if getIntercalation() {
            isoStr += " Intercalation"
        }
        
        return isoStr
    }
    
    /// 양력 날짜의 ISO 형식 문자열을 반환합니다.
    public func getSolarIsoFormat() -> String {
        let isoStr = String(format: "%04d-%02d-%02d", solarYear, solarMonth, solarDay)
        return isoStr
    }
    
    // MARK: - Getters & Setters
    
    /// 음력 연도를 반환합니다.
    public func getLunarYear() -> Int {
        return lunarYear
    }
    
    private func setLunarYear(_ lunarYear: Int) {
        self.lunarYear = lunarYear
    }
    
    /// 음력 월을 반환합니다.
    public func getLunarMonth() -> Int {
        return lunarMonth
    }
    
    private func setLunarMonth(_ lunarMonth: Int) {
        self.lunarMonth = lunarMonth
    }
    
    /// 음력 일을 반환합니다.
    public func getLunarDay() -> Int {
        return lunarDay
    }
    
    private func setLunarDay(_ lunarDay: Int) {
        self.lunarDay = lunarDay
    }
    
    /// 윤달 여부를 반환합니다.
    public func getIntercalation() -> Bool {
        return self.isIntercalation
    }
    
    private func setIntercalation(_ isIntercalation: Bool) {
        self.isIntercalation = isIntercalation
    }
    
    /// 양력 연도를 반환합니다.
    public func getSolarYear() -> Int {
        return solarYear
    }
    
    private func setSolarYear(_ solarYear: Int) {
        self.solarYear = solarYear
    }
    
    /// 양력 월을 반환합니다.
    public func getSolarMonth() -> Int {
        return solarMonth
    }
    
    private func setSolarMonth(_ solarMonth: Int) {
        self.solarMonth = solarMonth
    }
    
    /// 양력 일을 반환합니다.
    public func getSolarDay() -> Int {
        return solarDay
    }
    
    private func setSolarDay(_ solarDay: Int) {
        self.solarDay = solarDay
    }
}

