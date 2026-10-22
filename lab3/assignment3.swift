// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER CODE section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Use the exact function names from the assignment PDF.
// =============================================================


// MARK: - =================== STARTER CODE ===================
// MARK: - Do not modify anything in this section

typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each signature when you start working on it.


// MARK: Level 1 · Decoding Telemetry

// 1.1
func parseReading(_ raw: String) -> Reading? {
    guard let parts = splitOnce(raw, by: ":"),
          !parts.0.isEmpty,
          let value = Int(parts.1),
          value >= 0 || parts.0 == "TEMP" else {
        return nil
    }

    return (sensor: parts.0, value: value)
}

// Tests
print(parseReading("O2:87") as Any)
print(parseReading("TEMP:-12") as Any)
print(parseReading("RAD:-1") as Any)
print(parseReading(":55") as Any)


// 1.2
func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var valid: [Reading] = []
    var invalidCount = 0

    for line in lines {
        if let reading = parseReading(line) {
            valid.append(reading)
        } else {
            invalidCount += 1
        }
    }

    return (valid, invalidCount)
}

// Tests
print(parseLog(["O2:87", "TEMP:-12"]))
print(parseLog(["O2:87", "O2:abc", ":55"]))

let parsedLog = parseLog(rawLog)
let A = parsedLog.invalidCount

print("A =", A)

// MARK: Level 2 · Analysis

// 2.1
func select(
    _ readings: [Reading],
    where isIncluded: (Reading) -> Bool
) -> [Reading] {
    var result: [Reading] = []

    for reading in readings {
        if isIncluded(reading) {
            result.append(reading)
        }
    }

    return result
}

func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []

    for reading in readings {
        result.append(reading.value)
    }

    return result
}

let o2Readings = select(parsedLog.valid) {
    $0.sensor == "O2"
}

let o2Values = values(of: o2Readings)

print("O2 readings:", o2Readings)
print("O2 values:", o2Values)


// 2.2
func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard let first = values.first else {
        return nil
    }

    var min = first
    var max = first
    var sum = 0

    for value in values {
        if value < min {
            min = value
        }

        if value > max {
            max = value
        }

        sum += value
    }

    let average = Double(sum) / Double(values.count)

    return (min, max, average)
}

func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}

print(stats(3, 8, 1) as Any)
print(stats() as Any)

let o2Stats = stats(of: o2Values)
let B = Int(o2Stats?.average ?? 0)

print("B =", B)


// 2.3 · Closure Ladder

let sorted1 = parsedLog.valid.sorted(by: {
    (a: Reading, b: Reading) -> Bool in
    return a.value > b.value
})

let sorted2 = parsedLog.valid.sorted(by: {
    a, b in
    return a.value > b.value
})

let sorted3 = parsedLog.valid.sorted(by: {
    a, b in
    a.value > b.value
})

let sorted4 = parsedLog.valid.sorted(by: {
    $0.value > $1.value
})

let sorted5 = parsedLog.valid.sorted {
    $0.value > $1.value
}

let sameResults =
    values(of: sorted1) == values(of: sorted2) &&
    values(of: sorted2) == values(of: sorted3) &&
    values(of: sorted3) == values(of: sorted4) &&
    values(of: sorted4) == values(of: sorted5)

print("All sorts match:", sameResults)

// MARK: Level 3 · Temperature Stabilization

// 3.1
func heatUp(_ t: Int) -> Int {
    t + 5
}

func coolDown(_ t: Int) -> Int {
    t - 3
}

func hold(_ t: Int) -> Int {
    t
}

func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 {
        return heatUp
    } else if temp > 24 {
        return coolDown
    } else {
        return hold
    }
}

// Tests
print("Heat:", heatUp(10))
print("Cool:", coolDown(30))
print("Hold:", hold(20))


// 3.2
func runUntilStable(
    from start: Int,
    maxSteps: Int = 10
) -> (finalTemp: Int, steps: Int, isStable: Bool) {

    var temp = start
    var steps = 0

    while (temp < 18 || temp > 24) && steps < maxSteps {
        let protocolFunction = chooseProtocol(for: temp)
        temp = protocolFunction(temp)
        steps += 1
    }

    let isStable = temp >= 18 && temp <= 24

    return (temp, steps, isStable)
}

// Tests
print(runUntilStable(from: 31))
print(runUntilStable(from: -100, maxSteps: 5))


// Find lowest valid temperature
let tempReadings = select(parsedLog.valid) {
    $0.sensor == "TEMP"
}

let tempValues = values(of: tempReadings)
let tempStats = stats(of: tempValues)

let lowestTemp = tempStats?.min ?? 0
let stabilization = runUntilStable(from: lowestTemp)

let C = stabilization.steps

print("Lowest temperature:", lowestTemp)
print("Stabilization:", stabilization)
print("C =", C)

// MARK: Level 4 · The Crew

// 4.1
func oxygenLevel(of member: CrewMember) -> Int? {
    member.module?.oxygenTank?.level
}

// Tests
print(oxygenLevel(of: crew[0]) as Any)
print(oxygenLevel(of: crew[1]) as Any)


// 4.2
func status(of member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        let location = member.module?.name ?? "open space"
        return "\(member.name): no data (\(location))"
    }

    if level < 20 {
        return "\(member.name): \(level)% CRITICAL"
    } else {
        return "\(member.name): \(level)% OK"
    }
}

for member in crew {
    print(status(of: member))
}


// 4.3
@discardableResult
func transferOxygen(
    from source: inout Int,
    to target: inout Int,
    amount: Int
) -> Int {

    if amount < 0 {
        return 0
    }

    let availableSpace = 100 - target
    let actualAmount = min(amount, source, availableSpace)

    source -= actualAmount
    target += actualAmount

    return actualAmount
}

// Tests
var testSource = 50
var testTarget = 80

print(transferOxygen(
    from: &testSource,
    to: &testTarget,
    amount: 30
))

print(transferOxygen(
    from: &testSource,
    to: &testTarget,
    amount: -5
))


// Transfer Lab -> Hab
if let labTank = lab.oxygenTank,
   let habTank = hab.oxygenTank {

    let transferred = transferOxygen(
        from: &labTank.level,
        to: &habTank.level,
        amount: 30
    )

    print("Transferred:", transferred)
}

let D = hab.oxygenTank?.level ?? 0
print("D =", D)


// 4.4
func evacuationOrder(
    _ names: String...,
    roster: [String: CrewMember]
) -> [String] {

    var found: [CrewMember] = []

    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }

        found.append(member)
    }

    found.sort {
        $0.priority < $1.priority
    }

    var result: [String] = []

    for member in found {
        result.append(member.name)
    }

    return result
}

// Tests
print(evacuationOrder(
    "Dana",
    "Ghost",
    "Aigerim",
    "Timur",
    roster: roster
))

print(evacuationOrder(
    "Nurlan",
    "Timur",
    roster: roster
))

// MARK: Level 5 · The Saboteur's Logbook

// Problems in the original reportOxygen:
// 1. member.module! crashes if the member has no module.
// 2. oxygenTank! crashes if the module has no oxygen tank.

func reportOxygen(for member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no data"
    }

    return "\(member.name): \(level)%"
}


// Problems in the original firstCritical:
// 1. oxygenLevel(of:) can return nil, so using ! can crash.
// 2. result can stay nil if nobody is critical, so result! can crash.
// 3. It keeps searching after finding a critical member,
//    so it returns the last critical member instead of the first.

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        guard let level = oxygenLevel(of: member) else {
            continue
        }

        if level < 20 {
            return member.name
        }
    }

    return nil
}


// Tests
print(reportOxygen(for: crew[0]))
print(reportOxygen(for: crew[1]))

print("First critical:", firstCritical(in: crew) as Any)


// Logic bug test: both members are critical.
// The function must return "First", not "Second".

let testModule1 = Module(
    name: "Test1",
    oxygenTank: Tank(level: 10)
)

let testModule2 = Module(
    name: "Test2",
    oxygenTank: Tank(level: 5)
)

let testCrew = [
    CrewMember(
        name: "First",
        role: "Tester",
        priority: 1,
        module: testModule1
    ),
    CrewMember(
        name: "Second",
        role: "Tester",
        priority: 2,
        module: testModule2
    )
]

print("Logic test:", firstCritical(in: testCrew) as Any)

// MARK: Finale · Launch Code

let launchCode = "\(A)-\(B)-\(C)-\(D)"
print("LAUNCH CODE: \(launchCode)")


// MARK: Bonus

func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var count = 0

    return { level in
        if level < threshold {
            count += 1
            print("Alarm #\(count)")
            return true
        }

        return false
    }
}

// Tests
let alarm = makeAlarm(threshold: 20)

print(alarm(12))
print(alarm(40))
print(alarm(5))


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. guard let vs if let beyond syntax:

 guard let exits early if an optional is nil.
 The unwrapped value can be used after the guard.
 if let keeps the unwrapped value inside its block.
 guard let is useful when the value is required for the rest of the function.


 2. Why can't you pass [Int] to stats(_ values: Int...)?

 Int... means the function expects separate Int arguments,
 for example stats(3, 8, 1).
 Swift creates an [Int] inside the function, but we cannot
 pass an existing array directly to a variadic parameter.
 For an array, we use stats(of: someArray).


 3. Why doesn't transferOxygen(from: &x, to: &x, amount: 5) compile?

 Both parameters are inout, so both can modify the value.
 Passing the same variable creates overlapping write access.
 Swift prevents this to avoid unsafe changes to the same variable.


 4. Why doesn't oxygenLevel(of: dana) ?? "no data" compile?

 oxygenLevel returns Int?, but "no data" is a String.
 The value after ?? must have a compatible type.
 For example, oxygenLevel(of: member) ?? 0 works.


 5. Full type of chooseProtocol and how to read it:

 (Int) -> (Int) -> Int

 It takes an Int and returns another function.
 The returned function also takes an Int and returns an Int.
*/
