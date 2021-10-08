package jamstack

import (
	"encoding/json"
	// "list"
	// "strings"

	"alpha.dagger.io/dagger"
	"alpha.dagger.io/netlify"
	"alpha.dagger.io/js/yarn"

	multistage "github.com/grouville/dagger-multistaging/multistage"
)

gitRepo: {
	// Git remote
	remote: string | *"origin"
	// Git subdir
	subdir: string | *"/"
	// Git name
	name: string
	// Git email
	email: string
}

auth: {
	// Git Auth Token
	git: dagger.#Secret @dagger(input)
	// Netlify Auth Token
	netlify: dagger.#Secret @dagger(input)
}

yarnBuild: {
	"script": string | *"build"
	"buildDir": string | *"build"
	"env": [string]: string
	"cwd": *"." | string
}

// Reference provider
provider: *"github" | "gitlab"
// Reference refType
refType: *"pr" | "branch" | "tag"
// Source directory
source: dagger.#Artifact


refs: {
	multistage.#References & {
		repository: {
			authToken: auth.git
			"provider": provider
			"refType": refType
			"source": source
		}
		email: gitRepo.email
		name: gitRepo.name
	}
}.out

// tmpCheckouts: 

deployments: multistage.#Multistaging & {
	checkouts: {
		multistage.#Checkouts & {
			"refs": json.Unmarshal(refs)
			authToken: auth.git
		}
	}.out

	#template: {
		// Implement the standard #SimpleApp
		name: string
		src: dagger.#Artifact

		app: yarn.#Package & {
			"source": src
			"script": yarnBuild.script
			"buildDir": yarnBuild.buildDir
			"env": yarnBuild.env
			"cwd": yarnBuild.cwd
		}

		// jo: app.build
		// App-specific deployment config goes here:
		site: netlify.#Site & {
			account: token: auth.netlify
			contents: app.build
			"name": name
			// strings.Replace(
		// 		strings.Replace(name, "/", "-", -1),
		// 	".", "_", -1)
		}
	}
}