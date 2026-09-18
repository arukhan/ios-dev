//Easy tasks
// 1
let fruits: [String] = ["apple", "banana", "orange", "mango", "grape"]

print("Third fruit:")
print(fruits[2])

// 2
var favoriteNumbers: Set<Int> = [7, 3, 10, 21]

favoriteNumbers.insert(5)

print("\nUpdated set of favorite numbers:")
print(favoriteNumbers)

// 3
let programmingLanguages: [String: Int] = [
  "Swift": 2014,
  "Python": 1991,
  "Java": 1995,
]

print("\nSwift release year:")
print(programmingLanguages["Swift"]!)

// 4
var colors: [String] = ["red", "blue", "green", "yellow"]

colors[1] = "purple"

print("\nUpdated colors:")
print(colors)

//Medium tasks
// 1
let firstSet: Set<Int> = [1, 2, 3, 4]
let secondSet: Set<Int> = [3, 4, 5, 6]

let commonNumbers = firstSet.intersection(secondSet)

print("\nIntersection:")
print(commonNumbers)

// 2
var studentScores: [String: Int] = [
  "Arukhan": 90,
  "Amina": 85,
  "Dastan": 88,
]

studentScores.updateValue(95, forKey: "Arukhan")

print("\nUpdated student scores:")
print(studentScores)

// 3
let firstFruits: [String] = ["apple", "banana"]
let secondFruits: [String] = ["cherry", "date"]

let mergedFruits = firstFruits + secondFruits

print("\nMerged array:")
print(mergedFruits)

//Hard tasks
// 1
var countries: [String: Int] = [
  "Kazakhstan": 20_000_000,
  "France": 68_000_000,
  "Japan": 124_000_000,
]

countries["Canada"] = 41_000_000

print("\nUpdated countries dictionary:")
print(countries)

// 2
let animals1: Set<String> = ["cat", "dog"]
let animals2: Set<String> = ["dog", "mouse"]

let unitedAnimals = animals1.union(animals2)
let finalAnimals = unitedAnimals.subtracting(animals2)

print("\nFinal animal set:")
print(finalAnimals)

// 3
let studentGrades: [String: [Int]] = [
  "Arukhan": [90, 95, 100],
  "Amina": [85, 91, 87],
  "Daniel": [78, 84, 90],
]

print("\nArukhan's second grade:")
print(studentGrades["Arukhan"]![1])
