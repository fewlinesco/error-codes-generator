package main

import (
	"flag"
	"fmt"
	"os"
	"strconv"
	"time"

	"github.com/eknkc/basex"
)

func main() {

	var prefix string
	flag.StringVar(&prefix, "prefix", "", "provide a prefix for your error code, it usually is the first 3 letters of the name of the project you're working on")
	flag.Parse()

	now := time.Now()

	year := strconv.Itoa(now.Year() % 100)
	month := strconv.Itoa(int(now.Month()))
	day := strconv.Itoa(now.Day())
	hour := strconv.Itoa(now.Hour())
	minute := strconv.Itoa(now.Minute())
	second := strconv.Itoa(now.Second())
	microsecond := strconv.Itoa(now.Nanosecond() / 1000)

	part1 := base34Encode([]byte(month)) + base34Encode([]byte(day))
	part2 := fmt.Sprintf("%5v", base34Encode([]byte(hour+minute+second+microsecond)))

	fmt.Printf("%s_%s%s%s", prefix, year, part1, part2)
}

func base34Encode(source []byte) string {
	encoder, err := basex.NewEncoding("0123456789ABCDEFGHJKLMNPQRSTUVWXYZ")
	if err != nil {
		fmt.Fprintf(os.Stderr, "could not build the base34 encoder")
		os.Exit(1)
	}
	return encoder.Encode(source)
}
