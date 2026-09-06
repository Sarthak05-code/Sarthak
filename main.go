package main

import (
	"fmt"
	"strconv"
)

type Type int

const (
	Binary Type = iota
	Decimal
	Octal
	Hexadecimal
)

func convert(number int, target Type) string {
	switch target {
	case Binary:
		return strconv.FormatInt(int64(number), 2)

	case Decimal:
		return strconv.Itoa(number)

	case Octal:
		return strconv.FormatInt(int64(number), 8)

	case Hexadecimal:
		return strconv.FormatInt(int64(number), 16)

	default:
		return "Invalid Type"
	}
}

func main() {
	number := 1024

	fmt.Println("Binary     :", convert(number, Binary))
	fmt.Println("Decimal    :", convert(number, Decimal))
	fmt.Println("Octal      :", convert(number, Octal))
	fmt.Println("Hexadecimal:", convert(number, Hexadecimal))
}
