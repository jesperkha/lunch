package model

// Image represents a Docker image that has been built from a GitHub repository.
type Image struct {
	ID        int    `db:"id"`         // Unique identifier
	Name      string `db:"name"`       // Image name (typically repo name)
	Tag       string `db:"tag"`        // Image tag (e.g., "latest")
	RepoURL   string `db:"repo_url"`   // Source GitHub repository URL
	RepoPath  string `db:"repo_path"`  // Local path where repo was cloned
	ImagePath string `db:"image_path"` // Path to Dockerfile used for build
	CreatedAt string `db:"created_at"` // Timestamp when image was built
}
