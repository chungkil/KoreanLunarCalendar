import Testing
@testable import KoreanLunarCalendar

@Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
	let a = KoreanLunarCalendar()
	let ok = a.setSolarDate(solarYear: 2025, solarMonth: 4, solarDay: 1)
    if !ok {
        fatalError("set date failed")
    }
    print(a.getLunarIsoFormat())

    #expect(a.getLunarYear() == 2025)
    #expect(a.getLunarMonth() == 3)
    #expect(a.getLunarDay() == 4)
}
