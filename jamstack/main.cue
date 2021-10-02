package jamstack

import (
	"encoding/json"
	// "strings"

	"alpha.dagger.io/dagger"
	"alpha.dagger.io/netlify"
	// "alpha.dagger.io/js/yarn"

	multistage "github.com/grouville/dagger-multistaging/multistage"
)

// JAMStack deployment config
#Config: {
	// Git Auth Token
	gitAuthToken: { dagger.#Secret } @dagger(input)

	// Include inputs of `#Deployment` child definitions
	netlifyAccount: netlify.#Account
	
	yarn: {
		script: { string } @dagger(input)
		buildDir: { string } @dagger(input)
		env: { [string]: string } @dagger(input)
		cwd: { string } @dagger(input)
	}
}

#JAMStackDeployments: {
	config: #Config

	// Git Repo's refs
	refs: multistage.#References & {
		repository: {
			authToken: config.gitAuthToken
		}
	}

	// Computed refs exported as [name: #Artifact]
	computedRefs: multistage.#ComputedRefs & {
		"refs": json.Unmarshal(refs.out)
		"authToken": config.gitAuthToken
	}

	// out: {
	// 	[string]: {...}

	// 	// Loop on all deployments
	// 	for key, def in computedRefs.out {
	// 		"\(key)": {
	// 			//// Build JAMStack app
	// 			app: yarn.#Package & {
	// 				source: def.source
	// 				if config.yarn.script != _|_ {
	// 					script: config.yarn.script
	// 				}
	// 				if config.yarn.buildDir != _|_ {
	// 					buildDir: config.yarn.buildDir
	// 				}
	// 				if config.yarn.env != _|_ {
	// 					env: config.yarn.env
	// 				}
	// 				if config.yarn.cwd != _|_ {
	// 					cwd: config.yarn.cwd
	// 				}
	// 			}

	// 			//// Publish on Netlify
	// 			frontend: netlify.#Site & {
	// 				"account":  config.deploymentInputs.netlifyAccount
	// 				"contents": app.build
	// 				"name": strings.Replace(
	// 					strings.Replace(def.name, "/", "-", -1),
	// 				".", "_", -1)
	// 			}
	// 		}
	// 	}
	// }
}
