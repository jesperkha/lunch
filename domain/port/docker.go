package port

//go:generate mockgen -source=docker.go -destination=mocks/mock_docker.go -package=mocks

// DockerBuilder defines the interface for building Docker images.
type DockerBuilder interface {
	// BuildImage builds a Docker image from the specified Dockerfile.
	// The outputDir specifies where the built image context resides.
	BuildImage(dockerFile string, outputDir string) error
}
