package docker

import (
	"fmt"
	"lunch/domain/port"
	"os"
	"os/exec"
	"path/filepath"
)

// Builder implements the DockerBuilder interface.
type Builder struct{}

// NewBuilder creates a new Docker builder.
func NewBuilder() port.DockerBuilder {
	return &Builder{}
}

// BuildImage builds a Docker image from the specified Dockerfile.
// dockerFile is the path to the Dockerfile.
// outputDir is the build context directory where the image will be built from.
func (b *Builder) BuildImage(dockerFile string, outputDir string) error {
	// Verify the Dockerfile exists
	if _, err := os.Stat(dockerFile); os.IsNotExist(err) {
		return fmt.Errorf("dockerfile not found: %s", dockerFile)
	}

	// Verify the output directory exists
	if _, err := os.Stat(outputDir); os.IsNotExist(err) {
		return fmt.Errorf("output directory not found: %s", outputDir)
	}

	// Get the image name from the directory name
	imageName := filepath.Base(outputDir)

	// Build the Docker image
	cmd := exec.Command("docker", "build", "-f", dockerFile, "-t", imageName, outputDir)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		return fmt.Errorf("failed to build docker image: %w", err)
	}

	return nil
}
