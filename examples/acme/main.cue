package jamstack

import (
	"alpha.dagger.io/git"
	//debug
	"alpha.dagger.io/os"
	"alpha.dagger.io/dagger"
	// "alpha.dagger.io/alpine"

	jamstack "github.com/grouville/dagger-JAMStack/jamstack"
)

repoURL: "https://github.com/atulmy/crate.git"

reposi: git.#Repository & {
	remote: repoURL
	ref: "master"
	keepGitDir: true
	authToken: config.gitAuthToken
}

config: jamstack.#Config & {
	yarn: {
		env: {
			NODE_ENV: "production"
			APP_URL: "https://inexistantbackend.app/"
		}
		script: "build:client"
		buildDir: "public"
		cwd: "./crate/code/web"
	}
}

// deployment: jamstack.#JAMStackDeployments & {
// 	"config": config
// 	refs: repository: {
// 		source: reposi
// 		refType: "pr"
// 	}
// }

authToken: { dagger.#Secret } @dagger(input)
deployment: {
	"config": config
	refs: repository: {
		source: reposi
		refType: "pr"
		provider: "github"
		
	}
}

// DEBUG
// TestSubRepository: os.#Container & {
// 	image: alpine.#Image & {
// 		package: bash: "=5.1.0-r0"
// 		package: git:  true
// 	}
// 	mount: "/repo1": from: reposi
// 	dir: "/repo1"
// 	command: """
// 		git -c user.name=="grouville" -c user.email="guillaume.derouville@gmail.com"  ls-remote
// 		exit 1
// 		"""
// }

// Execute and extract from
ctr: os.#Container & {
	image: git.#Image & {
		package: jo: "=~1.4"
	}
	command: #Command
	dir: "/repo1"
	mount: "/repo1": from: reposi
	env: {
		USER_NAME:		deployment.refs.name
		USER_EMAIL:		deployment.refs.email
		REMOTE: 		reposi.remote
		if deployment.refs.repository.refType == "pr" && deployment.refs.repository.provider == "gitlab" {
			REF:		"merge-requests/*/head"
		}
		if deployment.refs.repository.refType == "pr" && deployment.refs.repository.provider == "github" {
			REF:		"pull/*/head"
		}
		if deployment.refs.repository.refType == "branch" {
			REF:		"refs/heads/*"
		}
		if deployment.refs.repository.refType == "tags" {
			REF:		"refs/tags"
		}
	}
	if deployment.refs.repository.authToken != null {
		env: GIT_ASKPASS: "/get_authToken"
		files: "/get_authToken": {
			content: "cat /secrets/authToken"
			mode:    0o500
		}
		secret: "/secrets/authToken": deployment.refs.repository.authToken
	}
}

#Command: #"""
    # Collect repo's URL in HTTPS format
    # Version control agnostic command (Github/Gitlab)
    # protocol agnostic (SSH or HTTPS Base url)
    #HTTPS='https://'
    #URL=$(git -c user.name="$USER_NAME" -c user.email="$USER_EMAIL" ls-remote --get-url "$REMOTE" |
    #    sed 's/https:\/\///' | sed 's/git@//' | tr ':' '/' | head -n 1)

    # Collect references
    #REFERENCES=$(jo -e -a $(git -c user.name="$USER_NAME" -c user.email="$USER_EMAIL" ls-remote "$REMOTE" "$REF" -q |
    #    cut -d$'\t' -f 2 | sed '/\^/d' | sed '/HEAD/d'))

    # Compute as JSON
    #jo -p url="$HTTPS$URL" references=$REFERENCES > /output.json
    echo "-----------------------------------DEBUG----------------------" >&2
    ls -a >&2
    git -c user.name="$USER_NAME" -c user.email="$USER_EMAIL" ls-remote "$REMOTE" >&2
    #git remote -v >&2
    """#