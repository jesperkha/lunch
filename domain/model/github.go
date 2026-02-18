package model

// GithubRepo represents a GitHub repository that has been pulled locally.
type GithubRepo struct {
	Name          string // Repository name
	URL           string // Repository URL
	Creator       string // Repository owner/creator
	HasDockerfile bool   // Whether the repo contains a Dockerfile
	LocalPath     string // Local path where the repo was cloned
}
