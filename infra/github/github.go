package github

import (
	"fmt"
	"lunch/domain/model"
	"lunch/domain/port"
	"lunch/pkg/github/ghclient"
	"os"
	"path/filepath"
)

// Repository implements the GithubRepository interface.
type Repository struct {
	client *ghclient.Client
}

// NewRepository creates a new GitHub repository handler.
func NewRepository() port.GithubRepository {
	return &Repository{
		client: ghclient.NewClient(),
	}
}

// PullGithubRepo clones a GitHub repository into the specified destination path.
// It fetches repository metadata from the GitHub API and checks for a Dockerfile.
func (r *Repository) PullGithubRepo(url string, destPath string) (model.GithubRepo, error) {
	// Get repository info from GitHub API
	info, err := r.client.GetRepoInfo(url)
	if err != nil {
		return model.GithubRepo{}, fmt.Errorf("failed to get repo info: %w", err)
	}

	// Create the destination directory if it doesn't exist
	if err := os.MkdirAll(destPath, 0755); err != nil {
		return model.GithubRepo{}, fmt.Errorf("failed to create destination directory: %w", err)
	}

	// Clone the repository
	repoPath := filepath.Join(destPath, info.Name)
	if err := r.client.CloneRepo(info.CloneURL, repoPath); err != nil {
		return model.GithubRepo{}, fmt.Errorf("failed to clone repo: %w", err)
	}

	// Check if Dockerfile exists in the cloned repository
	hasDockerfile := checkForDockerfile(repoPath)

	return model.GithubRepo{
		Name:          info.Name,
		URL:           info.HTMLURL,
		Creator:       info.Owner.Login,
		HasDockerfile: hasDockerfile,
		LocalPath:     repoPath,
	}, nil
}

// checkForDockerfile checks if a Dockerfile exists in the repository root.
func checkForDockerfile(repoPath string) bool {
	dockerfilePath := filepath.Join(repoPath, "Dockerfile")
	_, err := os.Stat(dockerfilePath)
	return err == nil
}
