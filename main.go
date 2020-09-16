package main

import (
	"fmt"
	"math/rand"
	"os"
	"time"
)

var projects = map[string]string{
	"catalog":  "CAT",
	"checkout": "CHE",
	"connect":  "CON",
	"offer":    "OFF",
	"sparta":   "SPA",
}

func main() {

	var project string

	if len(os.Args) < 2 {
		fmt.Fprintf(os.Stderr, "provide the name of the project you are currently working on as a command argument")
		printAvailableProjects()
		os.Exit(1)
	}

	project = os.Args[1]

	prefix := getProjectPrefix(project)
	if prefix == "" {
		fmt.Fprintf(os.Stderr, "%s is not a known project, please input one of the following project name or add it through a Pull Request\n", project)
		printAvailableProjects()
		os.Exit(1)
	}

	now := time.Now()
	code := generate(prefix, now, 4)

	fmt.Println(code)
}

func printAvailableProjects() {
	fmt.Println("Available project are:")
	for k := range projects {
		fmt.Printf("\t - %s\n", k)
	}
}

func randomString(size int) string {
	rand.Seed(time.Now().UnixNano())

	disambiguatedAlphabet := []byte("ABCDEFGHJKLMNPQRSTUVWXYZ")
	lenAlphabet := len(disambiguatedAlphabet)
	res := make([]byte, size)

	for i := 0; i < size; i++ {
		randomIndex := rand.Intn(lenAlphabet)
		res[i] = disambiguatedAlphabet[randomIndex]
	}

	return string(res)
}

func getProjectPrefix(project string) string {
	return projects[project]
}

func generate(prefix string, now time.Time, saltSize int) string {
	year := (now.Year() % 100)
	month := (int(now.Month()))
	day := (now.Day())

	salt := randomString(saltSize)

	return fmt.Sprintf("%s_%02d%02d%02d_%s", prefix, year, month, day, salt)
}
