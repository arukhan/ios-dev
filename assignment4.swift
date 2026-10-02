// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================

// MARK:My solution: Level 1 · The Deck Register

// 1.1
enum Deck: String, CaseIterable {
    case bridge
    case lab
    case cargo
    case medbay
    case engine

    var evacuationPriority: Int {
        switch self {
        case .bridge:
            return 1
        case .medbay:
            return 2
        case .lab:
            return 3
        case .engine:
            return 4
        case .cargo:
            return 5
        }
    }
}

for deck in Deck.allCases {
    print("Deck:", deck.rawValue,
          "Priority:", deck.evacuationPriority)
}

print("Bridge priority:", Deck.bridge.evacuationPriority)


// 1.2
enum AlarmLevel: Int {
    case green = 0
    case yellow
    case orange
    case red

    static func level(forTotalMass mass: Int) -> AlarmLevel {
        let calculatedLevel = mass / 500
        let safeLevel = calculatedLevel >= 3 ? 3 : calculatedLevel

        return AlarmLevel(rawValue: safeLevel) ?? .green
    }
}

// Tests
print("Alarm 0 kg:",
      AlarmLevel.level(forTotalMass: 0))

print("Alarm 940 kg:",
      AlarmLevel.level(forTotalMass: 940))

print("Alarm 4000 kg:",
      AlarmLevel.level(forTotalMass: 4000))


// MARK: Level 2 · The Manifest

// 2.1
enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}


// 2.2
func parseEntry(_ line: String) -> ManifestEntry {

    let parts = fields(line)

    if parts.count == 3 && parts[0] == "crate" {
        guard let id = Int(parts[1]),
              let mass = Int(parts[2]) else {
            return .unknown(raw: line)
        }

        return .crate(id: id, massKg: mass)
    }

    if parts.count == 3 && parts[0] == "container" {
        guard let mass = Int(parts[2]) else {
            return .unknown(raw: line)
        }

        return .container(
            code: parts[1],
            massKg: mass
        )
    }

    if parts.count == 4 && parts[0] == "livestock" {
        guard let count = Int(parts[2]),
              let massPerUnit = Int(parts[3]) else {
            return .unknown(raw: line)
        }

        return .livestock(
            species: parts[1],
            count: count,
            massPerUnitKg: massPerUnit
        )
    }

    return .unknown(raw: line)
}


// 2.3
func mass(of entry: ManifestEntry) -> Int {

    switch entry {

    case .crate(let id, let massKg):
        print("Crate \(id)")
        return massKg

    case .container(let code, let massKg):
        print("Container \(code)")
        return massKg

    case .livestock(let species,
                    let count,
                    let massPerUnitKg):
        print("Livestock \(species)")
        return count * massPerUnitKg

    case .unknown(let raw):
        print("Unknown entry:", raw)
        return 0
    }
}


var parsedManifest: [ManifestEntry] = []
var totalManifestMass = 0
var unknownCount = 0

for line in rawManifest {

    let entry = parseEntry(line)

    parsedManifest.append(entry)
    totalManifestMass += mass(of: entry)

    switch entry {
    case .unknown:
        unknownCount += 1
    default:
        break
    }
}

print("Manifest entries:", parsedManifest.count)
print("Unknown entries:", unknownCount)
print("Total manifest mass:", totalManifestMass)

let A = totalManifestMass

print("A =", A)


// MARK: Level 3 · Crew Snapshots

// 3.1
struct CrewSnapshot {

    let name: String
    var deck: Deck
    var oxygen: Int

    mutating func breathe(_ amount: Int) {

        oxygen -= amount

        if oxygen < 0 {
            oxygen = 0
        }
    }

    mutating func move(to deck: Deck) {
        self.deck = deck
    }

    mutating func reviveInMedbay() {

        self = CrewSnapshot(
            name: name,
            deck: .medbay,
            oxygen: 100
        )
    }

    static func rookie(named name: String) -> CrewSnapshot {

        CrewSnapshot(
            name: name,
            deck: .bridge,
            oxygen: 100
        )
    }
}


// Tests
var rookie1 = CrewSnapshot.rookie(named: "Test Rookie")
print("Rookie:", rookie1.name,
      rookie1.deck.rawValue,
      rookie1.oxygen)

rookie1.breathe(30)
print("After breathing:", rookie1.oxygen)

rookie1.move(to: .lab)
print("After move:", rookie1.deck.rawValue)

rookie1.reviveInMedbay()
print("After revive:",
      rookie1.deck.rawValue,
      rookie1.oxygen)


// 3.2 · Build roster

var crewRoster: [CrewSnapshot] = []

for record in crewData {

    guard let deck = Deck(rawValue: record.deck) else {
        print("Warning: unknown deck for \(record.name): \(record.deck)")
        continue
    }

    let member = CrewSnapshot(
        name: record.name,
        deck: deck,
        oxygen: record.oxygen
    )

    crewRoster.append(member)
}

print("Crew roster count:", crewRoster.count)

for member in crewRoster {
    print(
        member.name,
        member.deck.rawValue,
        member.oxygen
    )
}


// 3.3 · Value-semantics demonstration

if crewRoster.count > 0 {

    print("\n--- VALUE SEMANTICS: COPY ---")

    let original = crewRoster[0]
    var copy = original

    print("Before original:", original.oxygen)
    print("Before copy:", copy.oxygen)

    copy.breathe(10)

    print("After original:", original.oxygen)
    print("After copy:", copy.oxygen)
}


func changeSnapshot(_ snapshot: CrewSnapshot) {

    var localCopy = snapshot

    print("Inside plain function before:",
          localCopy.oxygen)

    localCopy.breathe(10)

    print("Inside plain function after:",
          localCopy.oxygen)
}

if crewRoster.count > 0 {

    let member = crewRoster[0]

    print("\n--- PLAIN PARAMETER ---")
    print("Original before:", member.oxygen)

    changeSnapshot(member)

    print("Original after:", member.oxygen)
}


func changeSnapshotInout(_ snapshot: inout CrewSnapshot) {

    print("Inside inout before:",
          snapshot.oxygen)

    snapshot.breathe(10)

    print("Inside inout after:",
          snapshot.oxygen)
}

if crewRoster.count > 0 {

    var member = crewRoster[0]

    print("\n--- INOUT PARAMETER ---")
    print("Original before:", member.oxygen)

    changeSnapshotInout(&member)

    print("Original after:", member.oxygen)
}


// MARK: Level 4 · The Teleport Pod

// 4.1
final class TeleportPod {

    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?

    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }

    func load(_ crew: CrewSnapshot) -> Bool {

        if occupant != nil {
            return false
        }

        if chargeLevel < 20 {
            return false
        }

        occupant = crew
        return true
    }

    func fire() -> CrewSnapshot? {

        guard let currentOccupant = occupant else {
            return nil
        }

        guard chargeLevel >= 20 else {
            return nil
        }

        chargeLevel -= 20
        occupant = nil

        return currentOccupant
    }

    deinit {
        print("TeleportPod \(id) deinitialized")
    }
}


// Tests
let testPod = TeleportPod(
    id: "TEST",
    chargeLevel: 100
)

print("Test pod charge:", testPod.chargeLevel)

if crewRoster.count > 0 {
    print("Test pod load:", testPod.load(crewRoster[0]))
}


// 4.2 · Charge ledger

let podP1 = TeleportPod(
    id: "P-1",
    chargeLevel: 100
)


var timur: CrewSnapshot?
var dana: CrewSnapshot?
var nurlan: CrewSnapshot?

for member in crewRoster {

    if member.name == "Timur" {
        timur = member
    }

    if member.name == "Dana" {
        dana = member
    }

    if member.name == "Nurlan" {
        nurlan = member
    }
}


// 1. Timur
if let member = timur {

    print("\nLoad Timur:",
          podP1.load(member))

    print("Charge after load Timur:",
          podP1.chargeLevel)

    let fired = podP1.fire()

    print("Fire Timur:",
          fired?.name ?? "none")

    print("Charge after fire Timur:",
          podP1.chargeLevel)
}


// 2. Dana
if let member = dana {

    print("\nLoad Dana:",
          podP1.load(member))

    print("Charge after load Dana:",
          podP1.chargeLevel)

    let fired = podP1.fire()

    print("Fire Dana:",
          fired?.name ?? "none")

    print("Charge after fire Dana:",
          podP1.chargeLevel)
}


// 3. Nurlan
if let member = nurlan {

    print("\nLoad Nurlan:",
          podP1.load(member))

    print("Charge after load Nurlan:",
          podP1.chargeLevel)

    let fired = podP1.fire()

    print("Fire Nurlan:",
          fired?.name ?? "none")

    print("Charge after fire Nurlan:",
          podP1.chargeLevel)
}


// 4. Empty fire
print("\nFire empty pod:",
      podP1.fire() as Any)

print("Charge after empty fire:",
      podP1.chargeLevel)

let C = podP1.chargeLevel

print("C =", C)


// 4.3 · Reference semantics

print("\n--- REFERENCE SEMANTICS ---")

let firstPodReference = TeleportPod(
    id: "REF",
    chargeLevel: 100
)

let secondPodReference = firstPodReference

print("Before first:", firstPodReference.chargeLevel)
print("Before second:", secondPodReference.chargeLevel)

secondPodReference.chargeLevel = 25

print("After first:", firstPodReference.chargeLevel)
print("After second:", secondPodReference.chargeLevel)


var firstSnapshot = CrewSnapshot.rookie(
    named: "Reference Test"
)

var secondSnapshot = firstSnapshot

print("Snapshot 1 before:",
      firstSnapshot.oxygen)

print("Snapshot 2 before:",
      secondSnapshot.oxygen)

secondSnapshot.oxygen = 20

print("Snapshot 1 after:",
      firstSnapshot.oxygen)

print("Snapshot 2 after:",
      secondSnapshot.oxygen)

// Rule:
// Struct assignment creates an independent value,
// while class assignment shares the same object.


// MARK: Level 5 · Station Systems

// 5.1
final class Station {

    // Stored let property
    let callSign: String

    // Stored var property with observers
    var hullIntegrity: Int {

        willSet {
            print(
                "Hull integrity:",
                hullIntegrity,
                "->",
                newValue
            )
        }

        didSet {

            if hullIntegrity > 100 {
                hullIntegrity = 100
            }

            if hullIntegrity < 0 {
                hullIntegrity = 0
            }
        }
    }

    // Stored property
    var oxygenByDeck: [Deck: Int]

    // Lazy stored property
    lazy var fullDiagnostics: String = {

        print("Running full scan...")

        return "Diagnostics for \(callSign): oxygen \(totalOxygen), hull \(hullIntegrity)"
    }()

    // Computed read-only property
    var totalOxygen: Int {

        var total = 0

        for oxygen in oxygenByDeck.values {
            total += oxygen
        }

        return total
    }

    // Computed get + set property
    var averageOxygen: Int {

        get {

            if oxygenByDeck.isEmpty {
                return 0
            }

            return totalOxygen / oxygenByDeck.count
        }

        set {

            for deck in oxygenByDeck.keys {
                oxygenByDeck[deck] = newValue
            }
        }
    }

    init(
        callSign: String,
        hullIntegrity: Int,
        readings: [(deck: String, oxygen: Int)]
    ) {

        self.callSign = callSign
        self.hullIntegrity = hullIntegrity
        self.oxygenByDeck = [:]

        for reading in readings {

            guard let deck = Deck(
                rawValue: reading.deck
            ) else {

                print(
                    "Warning: invalid deck reading:",
                    reading.deck
                )

                continue
            }

            self.oxygenByDeck[deck] =
                reading.oxygen
        }
    }
}


let station = Station(
    callSign: "ALMA-7",
    hullIntegrity: 100,
    readings: deckReadings
)

let B = station.averageOxygen

print("Starting total oxygen:",
      station.totalOxygen)

print("Starting average oxygen:",
      station.averageOxygen)

print("B =", B)


// Test average setter
station.averageOxygen = 50

print("Average after setter:",
      station.averageOxygen)

print("Total after setter:",
      station.totalOxygen)


print("\nBefore first diagnostics access")

print(station.fullDiagnostics)

print("After first diagnostics access")

print(station.fullDiagnostics)


let quietStation = Station(
    callSign: "QUIET",
    hullIntegrity: 90,
    readings: deckReadings
)

print(
    "Quiet station created without accessing diagnostics:",
    quietStation.callSign
)


// 5.2 · Clamp trap

station.hullIntegrity = 130
print("After 130:", station.hullIntegrity)

station.hullIntegrity = -40
print("After -40:", station.hullIntegrity)

station.hullIntegrity = 55
print("After 55:", station.hullIntegrity)

// Assigning hullIntegrity inside didSet does not recursively
// call the property observers again, so it does not loop forever.


// MARK: Level 6 · Incident Reports


// REPORT 1
//
// EXPECTED:
// The author expected every member in roster to lose 10 oxygen.
//
// ACTUAL:
// "member" is only a copy because CrewSnapshot is a struct.
// Changing it does not change the element stored in the array.
//
// RULE:
// Structs have value semantics.
//
// FIX:

var fixedRoster1 = crewRoster

print("\nReport 1 before:",
      fixedRoster1[0].oxygen)

for index in fixedRoster1.indices {
    fixedRoster1[index].oxygen -= 10
}

print("Report 1 after:",
      fixedRoster1[0].oxygen)


// REPORT 2
//
// EXPECTED:
// The author expected podA to stay at 100.
//
// ACTUAL:
// podA and podB reference the same TeleportPod.
// Changing podB also changes what podA sees.
//
// RULE:
// Classes have reference semantics.
//
// FIX:
// Create a separate object if independent state is required.

let fixedPodA = TeleportPod(
    id: "A",
    chargeLevel: 100
)

let fixedPodB = TeleportPod(
    id: "A-copy",
    chargeLevel: fixedPodA.chargeLevel
)

print("Report 2 before A:",
      fixedPodA.chargeLevel)

print("Report 2 before B:",
      fixedPodB.chargeLevel)

fixedPodB.chargeLevel = 0

print("Report 2 after A:",
      fixedPodA.chargeLevel)

print("Report 2 after B:",
      fixedPodB.chargeLevel)


// REPORT 3
//
// EXPECTED:
// add() should append an entry.
//
// ACTUAL:
// It does not compile because Logbook is a struct and
// add() tries to modify a stored property.
//
// RULE:
// A struct method that changes self or its properties
// must be marked mutating.
//
// FIX:

struct Logbook {

    var entries: [String] = []

    mutating func add(_ entry: String) {
        entries.append(entry)
    }
}

var logbook = Logbook()

print("Report 3 before:",
      logbook.entries)

logbook.add("Teleport started")

print("Report 3 after:",
      logbook.entries)


// REPORT 4
//
// EXPECTED:
// The author expects both let values to allow property changes.
//
// ACTUAL:
// snapshot.oxygen = 40 does NOT compile.
// pod.chargeLevel = 10 DOES compile.
//
// RULE:
// A let struct freezes the entire value.
// A let class constant freezes only the reference,
// not the mutable properties of the referenced object.
//
// FIX FOR STRUCT:
// Use var if the CrewSnapshot needs to change.

var fixedSnapshot =
    CrewSnapshot.rookie(named: "Dana")

print("Report 4 snapshot before:",
      fixedSnapshot.oxygen)

fixedSnapshot.oxygen = 40

print("Report 4 snapshot after:",
      fixedSnapshot.oxygen)


// A class reference may remain let.
let report4Pod = TeleportPod(
    id: "B",
    chargeLevel: 50
)

print("Report 4 pod before:",
      report4Pod.chargeLevel)

report4Pod.chargeLevel = 10

print("Report 4 pod after:",
      report4Pod.chargeLevel)


// MARK: Level 7 · Sealing the Black Box


final class FlightRecorder {

    // private blocks direct access to the stored history.
    private var entries: [String] = []

    // private(set) blocks outside code from changing the seal.
    private(set) var isSealed: Bool = false

    // Public read-only information.
    var entryCount: Int {
        entries.count
    }

    var transcript: String {

        var text = ""

        for entry in entries {

            if !text.isEmpty {
                text += "\n"
            }

            text += entry
        }

        return text
    }

    func add(_ entry: String) -> Bool {

        if isSealed {
            return false
        }

        entries.append(entry)
        return true
    }

    func seal() {
        isSealed = true
    }

    // fileprivate allows the free audit function in this file
    // to access this helper, while other files cannot.
    fileprivate func auditText() -> String {
        "Entries: \(entryCount)\n\(transcript)"
    }
}


// Free function using fileprivate helper
func auditTranscript(
    of recorder: FlightRecorder
) -> String {

    recorder.auditText()
}


// Tests
let recorder = FlightRecorder()

print("Recorder add 1:",
      recorder.add("System online"))

print("Recorder add 2:",
      recorder.add("Teleport ready"))

print("Recorder count:",
      recorder.entryCount)

print("Recorder transcript:")
print(recorder.transcript)

print("Audit:")
print(auditTranscript(of: recorder))

recorder.seal()

print("Recorder sealed:",
      recorder.isSealed)

print(
    "Add after seal:",
    recorder.add("This must not be added")
)

print("Final recorder count:",
      recorder.entryCount)


// Failed attempts:
//
// recorder.entries = []
// Error: 'entries' is inaccessible due to 'private' protection level
//
// recorder.isSealed = false
// Error: cannot assign to property: 'isSealed' setter is inaccessible


// MARK: Finale · Integrity Code

let D =
    AlarmLevel.level(forTotalMass: A).rawValue

let integrityCode =
    "\(A)-\(B)-\(C)-\(D)"

print("A =", A)
print("B =", B)
print("C =", C)
print("D =", D)

print("INTEGRITY CODE: \(integrityCode)")


// MARK: Bonus

// === checks whether two class references
// point to exactly the same object.

func samePod(
    _ first: TeleportPod,
    _ second: TeleportPod
) -> Bool {

    first === second
}

let identityPod1 = TeleportPod(
    id: "IDENTITY",
    chargeLevel: 50
)

let identityPod2 = identityPod1

let identityPod3 = TeleportPod(
    id: "IDENTITY",
    chargeLevel: 50
)

print(
    "Same object:",
    samePod(identityPod1, identityPod2)
)

print(
    "Different objects:",
    samePod(identityPod1, identityPod3)
)


// Lifetime / deinit experiment

print("\nBefore do block")

do {

    let temporaryPod = TeleportPod(
        id: "TEMP",
        chargeLevel: 40
    )

    let secondReference = temporaryPod

    print(
        "Inside block:",
        temporaryPod.id
    )

    print(
        "Second reference:",
        secondReference.id
    )

    print("Leaving do block")
}

// deinit for TEMP happens after both references
// leave scope at the end of the do block.

print("After do block")


//DEFENSE QUESTIONS
/*

1. Why did CrewSnapshot get an initializer for free
   while TeleportPod did not?

CrewSnapshot is a struct, so Swift automatically gives it
a memberwise initializer for its stored properties.
Classes do not get this memberwise initializer, so
TeleportPod needs its own init.


2. What does mutating do to self,
   and why do classes never need it?

mutating allows a struct method to change its properties
or replace self with a new value.
Classes use reference semantics, so their methods can change
var properties without the mutating keyword.


3. In Report 4 both values are let.
   What does let freeze for a struct and a class?

For a struct, let freezes the whole value, so its properties
cannot be changed.
For a class, let freezes the reference, but mutable properties
of the referenced object can still change.


4. Why must a lazy property be var?
   When does lazy change behaviour?

A lazy property is created only on its first access, so its
stored value must be assigned after initialization.
That is why it must be var.

Lazy changes behaviour when initialization has a side effect.
For example, fullDiagnostics prints "Running full scan..."
only if the property is actually accessed.


5. private vs fileprivate in FlightRecorder:

private restricts access to the declaration's enclosing scope,
so it is appropriate for the entries storage.

The audit helper must be called by auditTranscript outside
the class but in the same file, so fileprivate is appropriate.


BONUS:

deinit for TEMP runs when the do block ends because both
references to the temporary pod leave scope and the reference
count reaches zero.

=== works only with class instances because it compares object
identity. CrewSnapshot is a struct and has value semantics,
so === cannot be used with it.

*/