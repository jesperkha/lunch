package port

import "lunch/domain/model"

// GithubRepository defines the interface for GitHub repository operations.
type GithubRepository interface {
	// PullGithubRepo clones a GitHub repository into the specified destination path.
	// Returns a GithubRepo model containing repository metadata.
	PullGithubRepo(url string, destPath string) (model.GithubRepo, error)
}
