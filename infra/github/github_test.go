package github

import (
	"os"
	"path/filepath"
	"testing"
)

func TestPullGithubRepo(t *testing.T) {
	// Create a temporary directory for the test
	tempDir, err := os.MkdirTemp("", "lunch-github-test-*")
	if err != nil {
		t.Fatalf("failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tempDir)

	repo := NewRepository()

	// Test pulling the lunch repository
	result, err := repo.PullGithubRepo("github.com/jesperkha/lunch", tempDir)
	if err != nil {
		t.Fatalf("PullGithubRepo failed: %v", err)
	}

	// Verify repository metadata
	if result.Name != "lunch" {
		t.Errorf("expected repo name 'lunch', got '%s'", result.Name)
	}

	if result.Creator != "jesperkha" {
		t.Errorf("expected creator 'jesperkha', got '%s'", result.Creator)
	}

	if result.URL != "https://github.com/jesperkha/lunch" {
		t.Errorf("expected URL 'https://github.com/jesperkha/lunch', got '%s'", result.URL)
	}

	// Verify the repo was cloned to the expected path
	expectedPath := filepath.Join(tempDir, "lunch")
	if result.LocalPath != expectedPath {
		t.Errorf("expected local path '%s', got '%s'", expectedPath, result.LocalPath)
	}

	// Verify the directory exists
	if _, err := os.Stat(result.LocalPath); os.IsNotExist(err) {
		t.Errorf("cloned repository directory does not exist at '%s'", result.LocalPath)
	}

	// Verify that key files exist (like go.mod)
	goModPath := filepath.Join(result.LocalPath, "go.mod")
	if _, err := os.Stat(goModPath); os.IsNotExist(err) {
		t.Error("go.mod not found in cloned repository")
	}

	// Log the Dockerfile status (this repo may or may not have one)
	t.Logf("Repository has Dockerfile: %v", result.HasDockerfile)
}

func TestPullGithubRepo_InvalidURL(t *testing.T) {
	tempDir, err := os.MkdirTemp("", "lunch-github-test-*")
	if err != nil {
		t.Fatalf("failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tempDir)

	repo := NewRepository()

	// Test with invalid URL
	_, err = repo.PullGithubRepo("invalid-url", tempDir)
	if err == nil {
		t.Error("expected error for invalid URL, got nil")
	}
}

func TestPullGithubRepo_NonExistentRepo(t *testing.T) {
	tempDir, err := os.MkdirTemp("", "lunch-github-test-*")
	if err != nil {
		t.Fatalf("failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tempDir)

	repo := NewRepository()

	// Test with non-existent repository
	_, err = repo.PullGithubRepo("github.com/jesperkha/nonexistent-repo-12345", tempDir)
	if err == nil {
		t.Error("expected error for non-existent repo, got nil")
	}
}
