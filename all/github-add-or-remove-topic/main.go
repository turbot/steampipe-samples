package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"os"
	"strings"

	"github.com/google/go-github/v32/github"
	_ "github.com/lib/pq"
	"golang.org/x/oauth2"
)

var query = `
	with names as (
		select
			replace(full_name, 'judell/', '') as name -- replace with your ownerLogin
		from
			github_my_repository
		where
			full_name ~ 'judell/(elmcity|facet)' -- replace with your ownerLogin and a pattern
		order by
			full_name desc
		)
		select
			array_to_string(array_agg(name), ',') as names 
		from
			names	
`

func CheckError(err error) {
	if err != nil {
		panic(err)
	}
}

// use db connection
func queryPostgresForRepos() string {
	host := "localhost"
	port := 9193
	user := "steampipe"
	password := os.Getenv("STEAMPIPE_LOCAL_PASSWORD")
	dbname := "steampipe"
	psqlconn := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s", host, port, user, password, dbname)
	db, err := sql.Open("postgres", psqlconn)
	CheckError(err)
	defer db.Close()
	rows, _ := db.Query(query)
	var names string
	for rows.Next() {
		err = rows.Scan(&names)
		CheckError(err)
	}
	return names
}

// use steampipe cloud query api
func querySpcForRepos() string {
	type Result struct {
		Items []struct {
			Names string `json:"names"`
		} `json:"items"`
	}
	uri := fmt.Sprintf("https://cloud.steampipe.io/api/latest/org/acme/workspace/jon/query?sql=%s", url.PathEscape(query)) //-- use your handle and workspace
	req, err := http.NewRequest("GET", uri, nil)
	CheckError(err)
	req.Header.Add("Authorization", fmt.Sprintf("Bearer %s", os.Getenv("STEAMPIPE_CLOUD_TOKEN")))
	resp, err := http.DefaultClient.Do(req)
	CheckError(err)
	defer resp.Body.Close()
	decoder := json.NewDecoder(resp.Body)
	var result Result
	err = decoder.Decode(&result)
	CheckError(err)
	return result.Items[0].Names
}

func main() {
	var accessToken = os.Getenv("GITHUB_TOKEN")

	ctx := context.Background()
	ts := oauth2.StaticTokenSource(
		&oauth2.Token{AccessToken: accessToken},
	)
	tc := oauth2.NewClient(ctx, ts)
	client := github.NewClient(tc)

	//names := queryPostgresForRepos()
	names := querySpcForRepos()

	var repos = strings.Split(names, ",")

	var ownerLogin = "judell"

	var topic = "test"

	for i, repoName := range repos {
		fmt.Printf("%v %v topic %s\n", i, repoName, topic)
		addTopic(ctx, client, ownerLogin, repoName, topic)
		//removeTopic(ctx, client, ownerLogin, repoName, topic)
	}
}

func addTopic(ctx context.Context, client *github.Client, ownerLogin string, repoName string, topic string) {
	var topics, _, err = client.Repositories.ListAllTopics(ctx, ownerLogin, repoName)
	fmt.Printf("topics:\n%v\n", topics)
	topics = append(topics, topic)
	finalTopics, _, err := client.Repositories.ReplaceAllTopics(ctx, ownerLogin, repoName, topics)
	if err != nil {
		fmt.Printf("%+v err  \n", err)
	}
	fmt.Printf("mode: add \nfinalTopics:\n%v\n", finalTopics)
}

func removeTopic(ctx context.Context, client *github.Client, ownerLogin string, repoName string, topic string) {
	var topics, _, err = client.Repositories.ListAllTopics(ctx, ownerLogin, repoName)
	fmt.Printf("topics:\n%v\n", topics)
	var newTopics = []string{}
	for _, v := range topics {
		if v == topic {
			fmt.Printf("\nskipping %s", v)
		} else {
			newTopics = append(newTopics, v)
		}
	}
	finalTopics, _, err := client.Repositories.ReplaceAllTopics(ctx, ownerLogin, repoName, newTopics)
	if err != nil {
		fmt.Printf("%+v err  \n", err)
	}
	fmt.Printf("mode: remove \nfinalTopics:\n%v\n", finalTopics)
}
