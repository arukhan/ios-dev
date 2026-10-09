// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development · Module 5 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part3_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section. LegacyBeacon in
//     particular must be reached with an extension, not edited.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • The Health Rule must exist in exactly ONE place in this file.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================


// MARK: Level 1 - The Power Cell
// A class lets multiple drones or controllers share the same mutable power cell.
final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        self.charge = Swift.max(0, Swift.min(100, charge))
    }
    func level() -> Int { charge }
    func spend(_ amount: Int) -> Bool {
        guard amount > 0, charge >= amount else { return false }
        charge -= amount
        return true
    }
    func recharge(by amount: Int) {
        guard amount > 0 else { return }
        charge = Swift.min(100, charge + amount)
    }
}
let cell = PowerCell(charge: 150)
print("Cell clamped:", cell.level())
print("Spend 30:", cell.spend(30), "remaining:", cell.level())
cell.recharge(by: 100)
print("Recharge capped:", cell.level())
// cell.charge = 100
// error: 'charge' is inaccessible due to 'private' protection level

// MARK: Level 2 - The Fleet
class Drone {
    let id: String
    let cell: PowerCell
    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }
    var powerCost: Int { 10 }
    var statusLine: String { "\(id): \(cell.level())% \(cell.level().powerBar)" }
    func performTask() -> Int { 0 }
    // final ensures no subclass can bypass the shared power-spending ritual.
    final func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}
final class WelderDrone: Drone {
    override var powerCost: Int { 25 }
    override func performTask() -> Int { 40 }
    func weldSeam() -> String { "\(id) welded a seam" }
}
class ScannerDrone: Drone {
    override var powerCost: Int { 10 }
    override func performTask() -> Int { 15 }
    override var statusLine: String { super.statusLine + " [scanner]" }
}
final class CargoDrone: Drone {
    override var powerCost: Int { 20 }
    override func performTask() -> Int { 25 }
}
func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    switch kind {
    case "welder": return WelderDrone(id: id, cell: cell)
    case "scanner": return ScannerDrone(id: id, cell: cell)
    case "cargo": return CargoDrone(id: id, cell: cell)
    default: return nil
    }
}
var fleet: [Drone] = []
for record in fleetData {
    guard let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) else {
        print("Skipped unknown drone:", record.kind, record.id)
        continue
    }
    fleet.append(drone)
}
print("Fleet size:", fleet.count)
print("Welder example:", WelderDrone(id: "DEMO", cell: PowerCell(charge: 30)).weldSeam())

// MARK: Level 3 - The Shift
func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    guard rounds > 0 else { return 0 }
    var work = 0
    for _ in 0..<rounds {
        for drone in fleet { work += drone.runOnce() }
    }
    return work
}
let A = runShift(fleet, rounds: 3)
var B = 0
var C = 0
for drone in fleet {
    print(drone.statusLine)
    B += drone.cell.level()
    if drone.cell.level() >= drone.powerCost { C += 1 }
}
print("Shift work:", A, "remaining charge:", B, "ready drones:", C)

// MARK: Level 4 - Diagnostics
protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}
protocol Rechargeable {
    mutating func recharge(by amount: Int)
}
// The single implementation of the health rule is shared by all components.
extension Diagnosable {
    func healthCode(for charge: Int) -> Int {
        if charge < 20 { return 2 }
        if charge < 50 { return 1 }
        return 0
    }
    func diagnose() -> String { "\(componentID): code \(statusCode)" }
}
// Classes can mutate referenced objects without the mutating keyword.
extension Drone: Diagnosable, Rechargeable {
    var componentID: String { id }
    var statusCode: Int { healthCode(for: cell.level()) }
    func recharge(by amount: Int) { cell.recharge(by: amount) }
}
struct SensorModule: Diagnosable, Rechargeable {
    let componentID: String
    var chargeLevel: Int
    var statusCode: Int { healthCode(for: chargeLevel) }
    mutating func recharge(by amount: Int) {
        guard amount > 0 else { return }
        chargeLevel = Swift.min(100, Swift.max(0, chargeLevel) + amount)
    }
}
func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var lines: [String] = []
    for component in components { lines.append(component.diagnose()) }
    return lines.joined(separator: "\n")
}
var sensors: [SensorModule] = []
for record in sensorData {
    sensors.append(SensorModule(componentID: record.id, chargeLevel: record.charge))
}
// [Drone] cannot hold sensors because SensorModule is a struct, not a Drone subclass.
var components: [Diagnosable] = []
for drone in fleet { components.append(drone) }
for sensor in sensors { components.append(sensor) }
print("Diagnostics before beacon:\n" + diagnosticsReport(components))
if sensors.count > 0 {
    var sensorDemo = sensors[0]
    sensorDemo.recharge(by: 15)
    print("Sensor recharge demo:", sensorDemo.diagnose())
    // The original sensor array remains unchanged for the mission diagnostics.
}

// MARK: Level 5 - Shared Behaviour
extension LegacyBeacon: Diagnosable {
    var componentID: String { name }
    var statusCode: Int { healthCode(for: signalStrength) }
    func diagnose() -> String { "LEGACY BEACON \(componentID): code \(statusCode)" }
}
components.append(beacon)
print("Diagnostics with beacon:\n" + diagnosticsReport(components))
var D = 0
for component in components { D += component.statusCode }

extension Int {
    var powerBar: String {
        let bars = Swift.max(0, Swift.min(10, self / 10))
        var result = ""
        for i in 0..<10 { result += i < bars ? "#" : "." }
        return result
    }
}
print("Power bars:", 42.powerBar, (-5).powerBar, 250.powerBar)

// MARK: Level 6 - Incident Reports
// Report 1: Author expects 30 work. Actual: compiler error because overriding requires override.
// Fix: mark override; the inherited runOnce remains unchanged.
class PatchDrone: Drone {
    override func performTask() -> Int { 30 }
}
print("Report 1:", PatchDrone(id: "PATCH", cell: PowerCell(charge: 30)).runOnce())

// Report 2: Author expects 999 work. Actual: compilation fails: WelderDrone is final,
// and runOnce is final, so neither subclassing nor overriding is allowed.
// Fix: create a separate Drone subclass that overrides only performTask.
final class HeavyWelder: Drone {
    override var powerCost: Int { 25 }
    override func performTask() -> Int { 999 }
}
print("Report 2:", HeavyWelder(id: "HEAVY", cell: PowerCell(charge: 30)).runOnce())

// Report 3: Author expects weldSeam(). Actual: compiler error; first is statically Drone.
// Fix: a conditional downcast. as? returns an optional because the runtime object might not be a WelderDrone.
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
if let welder = first as? WelderDrone { print("Report 3:", welder.weldSeam()) }

// Report 4: Author expects "thruster T-1". Actual: "generic component".
// label() defined only in a protocol extension is statically dispatched through Labelled.
// Fix: declare label() as a protocol requirement so the concrete implementation is dispatched.
protocol Labelled {
    var componentID: String { get }
    func label() -> String
}
extension Labelled {
    func label() -> String { "generic component" }
}
struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}
let parts: [Labelled] = [Thruster(componentID: "T-1")]
print("Report 4:", parts[0].label())

// MARK: Finale - Mission Code
let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")

// MARK: Bonus - abstract-like alternatives and protocol-based redesign
// Runtime prohibition: in a base class initializer, precondition(type(of: self) != Drone.self)
// would trap if someone instantiated Drone directly. This is an illustration, not enabled
// because this lab intentionally permits a bare Drone for testing.
// Compile-time prohibition: use a protocol instead of an instantiable base class,
// as demonstrated below. A protocol cannot be directly initialized.
protocol FleetUnit {
    var unitID: String { get }
    var chargeLevel: Int { get set }
    var taskCost: Int { get }
    var workUnits: Int { get }
    mutating func runTask() -> Int
}
extension FleetUnit {
    mutating func runTask() -> Int {
        guard chargeLevel >= taskCost else { return 0 }
        chargeLevel -= taskCost
        return workUnits
    }
}
struct ValueWelderDrone: FleetUnit {
    let unitID: String
    var chargeLevel: Int
    let taskCost = 25
    let workUnits = 40
}
var alternativeFleet: [any FleetUnit] = [
    ValueWelderDrone(unitID: "VW-1", chargeLevel: 80),
    ValueWelderDrone(unitID: "VW-2", chargeLevel: 15)
]
var alternativeWork = 0
for i in alternativeFleet.indices { alternativeWork += alternativeFleet[i].runTask() }
print("Bonus protocol fleet work:", alternativeWork)
// The class design shares identity and mutable PowerCell references, which suits real drones.
// The protocol-and-struct design makes independent value snapshots and forbids direct
// instantiation of an empty base drone. Shared mutable state would require a reference
// holder (for example PowerCell) or explicit coordination with inout.

// MARK: - ================= DEFENSE QUESTIONS =================
/*
1. Classes use reference semantics, so methods may change their objects without mutating.
   Structs have value semantics and need mutating when changing stored properties.
2. Inheritance shares stored state and overridable implementations in a class hierarchy.
   Protocols unite unrelated types, including structs and classes, under one interface.
3. final prevents overriding a method or subclassing a final class. On runOnce it stops
   subclasses from skipping the power check or inventing a different charging ritual.
4. In the original Report 4, label was only an extension method, not a protocol requirement.
   Calls through Labelled therefore used the extension implementation, not Thruster's method.
*/
