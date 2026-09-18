import Foundation

let firstName: String = "Arukhan"
let lastName: String = "Kalikhan"

let birthYear: Int = 2006
let currentYear: Int = 2026
let age: Int = currentYear - birthYear

let isStudent: Bool = true
let height: Double = 1.65

let favoriteEmoji: String = ":)"
let languageLearning: String = "French"

let favoriteHobbies: String = "reading, drawing, and singing"
let numberOfHobbies: Int = 7
let favoriteNumber: Int = 7
let isHobbyCreative: Bool = true

let otherHobby1: String = "hiking"
let otherHobby2: String = "dancing"
let otherInterest: String = "watching films"


let futureGoals: String = "work, travel, and continue studying"


let studentStatus: String = isStudent
    ? "I am currently a student."
    : "I am not currently a student."

let hobbyDescription: String = isHobbyCreative
    ? "I consider my hobbies creative."
    : "I do not consider my hobbies creative."


let lifeStory: String = """
My name is \(firstName) \(lastName) \(favoriteEmoji).
I am \(age) years old and I was born in \(birthYear).
My height is \(height) meters.
\(studentStatus)

My favorite hobbies are \(favoriteHobbies).
\(hobbyDescription)
I also enjoy \(otherHobby1), \(otherHobby2), and \(otherInterest).
I have \(numberOfHobbies) hobbies in total, and my favorite number is \(favoriteNumber).

One interesting fact about me is that I am currently learning \(languageLearning).

In the future, I want to \(futureGoals).
"""

print(lifeStory)