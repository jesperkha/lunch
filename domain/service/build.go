package service

import (
	"fmt"
	"lunch/domain/port"
	"path/filepath"
)

// BuildService handles building Docker images from GitHub repositories.
type BuildService struct {
	githubRepo    port.GithubRepository
	dockerBuilder port.DockerBuilder
}

// NewBuildService creates a new BuildService with the given dependencies.
func NewBuildService(githubRepo port.GithubRepository, dockerBuilder port.DockerBuilder) *BuildService {
	return &BuildService{
		githubRepo:    githubRepo,
		dockerBuilder: dockerBuilder,
	}
}

// PullAndBuild clones a GitHub repository and builds its Docker image.
// url is the GitHub repository URL to clone.
// output is the directory where the repository will be cloned and the image built.
func (s *BuildService) PullAndBuild(url string, output string) error {
	// Clone the repository
	repo, err := s.githubRepo.PullGithubRepo(url, output)
	if err != nil {
		return fmt.Errorf("failed to pull repository: %w", err)
	}

	// Check if the repository has a Dockerfile
	if !repo.HasDockerfile {
		return fmt.Errorf("repository %s does not contain a Dockerfile", repo.Name)
	}

	// Build the Docker image
	dockerfilePath := filepath.Join(repo.LocalPath, "Dockerfile")
	if err := s.dockerBuilder.BuildImage(dockerfilePath, repo.LocalPath); err != nil {
		return fmt.Errorf("failed to build docker image: %w", err)
	}

	return nil
}
