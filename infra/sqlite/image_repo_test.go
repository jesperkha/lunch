package sqlite

import (
	"lunch/domain/model"
	"lunch/pkg/sqlite"
	"os"
	"testing"
)

func setupTestDB(t *testing.T) (*sqlite.Database, func()) {
	t.Helper()

	// Use in-memory SQLite database for tests
	db, err := sqlite.NewDatabase(":memory:")
	if err != nil {
		t.Fatalf("failed to create test database: %v", err)
	}

	if err := db.Migrate(); err != nil {
		t.Fatalf("failed to migrate test database: %v", err)
	}

	cleanup := func() {
		db.Close()
	}

	return db, cleanup
}

func TestImageRepo_New(t *testing.T) {
	db, cleanup := setupTestDB(t)
	defer cleanup()

	repo := NewImageRepo(db)

	image := model.Image{
		Name:      "test-image",
		Tag:       "latest",
		RepoURL:   "https://github.com/example/repo",
		RepoPath:  "/tmp/repos/repo",
		ImagePath: "/tmp/repos/repo/Dockerfile",
	}

	id, err := repo.New(image)
	if err != nil {
		t.Fatalf("failed to create image: %v", err)
	}

	if id <= 0 {
		t.Errorf("expected positive id, got %d", id)
	}
}

func TestImageRepo_New_DuplicateName(t *testing.T) {
	db, cleanup := setupTestDB(t)
	defer cleanup()

	repo := NewImageRepo(db)

	image := model.Image{
		Name:      "test-image",
		Tag:       "latest",
		RepoURL:   "https://github.com/example/repo",
		RepoPath:  "/tmp/repos/repo",
		ImagePath: "/tmp/repos/repo/Dockerfile",
	}

	_, err := repo.New(image)
	if err != nil {
		t.Fatalf("failed to create first image: %v", err)
	}

	// Try to create another image with the same name
	_, err = repo.New(image)
	if err == nil {
		t.Error("expected error for duplicate name, got nil")
	}
}

func TestImageRepo_GetById(t *testing.T) {
	db, cleanup := setupTestDB(t)
	defer cleanup()

	repo := NewImageRepo(db)

	image := model.Image{
		Name:      "test-image",
		Tag:       "v1.0",
		RepoURL:   "https://github.com/example/repo",
		RepoPath:  "/tmp/repos/repo",
		ImagePath: "/tmp/repos/repo/Dockerfile",
	}

	id, err := repo.New(image)
	if err != nil {
		t.Fatalf("failed to create image: %v", err)
	}

	retrieved, err := repo.GetById(id)
	if err != nil {
		t.Fatalf("failed to get image by id: %v", err)
	}

	if retrieved.ID != id {
		t.Errorf("expected id %d, got %d", id, retrieved.ID)
	}
	if retrieved.Name != image.Name {
		t.Errorf("expected name %s, got %s", image.Name, retrieved.Name)
	}
	if retrieved.Tag != image.Tag {
		t.Errorf("expected tag %s, got %s", image.Tag, retrieved.Tag)
	}
	if retrieved.RepoURL != image.RepoURL {
		t.Errorf("expected repo_url %s, got %s", image.RepoURL, retrieved.RepoURL)
	}
	if retrieved.RepoPath != image.RepoPath {
		t.Errorf("expected repo_path %s, got %s", image.RepoPath, retrieved.RepoPath)
	}
	if retrieved.ImagePath != image.ImagePath {
		t.Errorf("expected image_path %s, got %s", image.ImagePath, retrieved.ImagePath)
	}
}

func TestImageRepo_GetById_NotFound(t *testing.T) {
	db, cleanup := setupTestDB(t)
	defer cleanup()

	repo := NewImageRepo(db)

	_, err := repo.GetById(999)
	if err == nil {
		t.Error("expected error for non-existent id, got nil")
	}
	if err != ErrImageNotFound {
		t.Errorf("expected ErrImageNotFound, got %v", err)
	}
}

func TestImageRepo_GetByName(t *testing.T) {
	db, cleanup := setupTestDB(t)
	defer cleanup()

	repo := NewImageRepo(db)

	image := model.Image{
		Name:      "my-app",
		Tag:       "latest",
		RepoURL:   "https://github.com/example/my-app",
		RepoPath:  "/tmp/repos/my-app",
		ImagePath: "/tmp/repos/my-app/Dockerfile",
	}

	id, err := repo.New(image)
	if err != nil {
		t.Fatalf("failed to create image: %v", err)
	}

	retrieved, err := repo.GetByName("my-app")
	if err != nil {
		t.Fatalf("failed to get image by name: %v", err)
	}

	if retrieved.ID != id {
		t.Errorf("expected id %d, got %d", id, retrieved.ID)
	}
	if retrieved.Name != image.Name {
		t.Errorf("expected name %s, got %s", image.Name, retrieved.Name)
	}
}

func TestImageRepo_GetByName_NotFound(t *testing.T) {
	db, cleanup := setupTestDB(t)
	defer cleanup()

	repo := NewImageRepo(db)

	_, err := repo.GetByName("non-existent")
	if err == nil {
		t.Error("expected error for non-existent name, got nil")
	}
	if err != ErrImageNotFound {
		t.Errorf("expected ErrImageNotFound, got %v", err)
	}
}

func TestMain(m *testing.M) {
	// Run tests
	code := m.Run()
	os.Exit(code)
}
