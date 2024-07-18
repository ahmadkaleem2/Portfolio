package main

import (
	"fmt"
	"just-playing/helper"
)

func main() {
	fmt.Println("asdsadsads")

	greet_user("Any")
	sum := helper.Add_two_numbers(1, 2)
	fmt.Println(sum)
}

func greet_user(Name string) {
	fmt.Printf("Hello %v\n", Name)

}

// func add_two_numbers(first_number int, seconds_number int) int {
// 	return (first_number + seconds_number)

// }
