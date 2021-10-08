package jamstack

import(
	"alpha.dagger.io/git"
)

{
	yarnBuild: {
		env: {
			NODE_ENV: "production"
			APP_URL: "https://inexistantbackend.app/"
		}
		script: "build:client"
		buildDir: "public"
		cwd: "./crate/code/web"
	}
	gitRepo: {
		name: "grouville"
		email: "guillaume.derouville@gmail.com"
	}
	provider: "github"
	refType: "pr"
	source: git.#Repository & {
		remote: "https://github.com/atulmy/crate.git"
		ref: "master"
		keepGitDir: true
		authToken: auth.git
	}
}