package multistage

import (
	"alpha.dagger.io/dagger"
)

#Multistaging: {
	// Map of source code checkouts
	checkouts: [name=string]: dagger.#Artifact

	// Common configuration template for all deployments
	// (app-specifig deployment logic goes here)
	#template: {
		// #SimpleApp
		// source to deploy
		src: dagger.#Artifact
		// Unique name (for naming app-specific resources)
		name: string
		...
	}


	// Deploy each checkout
	// Live deployment (one per checkout)
	deployments: {
		[string]: {
			src: dagger.#Artifact
			name: string
			...
		}
		for name, checkout in checkouts {
			"\(name)": #template & {
				"src": checkout
				"name": name
			}
		}
	}
}

// Required fields for the callback
// #SimpleApp: {
// 	// source to deploy
// 	source: dagger.#Artifact
// 	// Unique name (for naming app-specific resources)
// 	name: string
// }