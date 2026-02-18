package sqlite

import (
	"database/sql"
	"errors"
	"fmt"
	"lunch/domain/model"
	"lunch/domain/port"
	"lunch/pkg/sqlite"
)

var (
	ErrImageNotFound = errors.New("image not found")
)

// ImageRepo implements the port.ImageRepo interface using SQLite.
type ImageRepo struct {
	db *sqlite.Database
}

// NewImageRepo creates a new ImageRepo with the given database connection.
func NewImageRepo(db *sqlite.Database) port.ImageRepo {
	return &ImageRepo{db: db}
}

// New stores a new image and returns its ID.
func (r *ImageRepo) New(image model.Image) (int, error) {
	query := `
		INSERT INTO images (name, tag, repo_url, repo_path, image_path, created_at)
		VALUES (:name, :tag, :repo_url, :repo_path, :image_path, datetime('now'))
	`

	result, err := r.db.NamedExec(query, image)
	if err != nil {
		return 0, fmt.Errorf("failed to insert image: %w", err)
	}

	id, err := result.LastInsertId()
	if err != nil {
		return 0, fmt.Errorf("failed to get last insert id: %w", err)
	}

	return int(id), nil
}

// GetById retrieves an image by its ID.
func (r *ImageRepo) GetById(id int) (model.Image, error) {
	var image model.Image
	query := `SELECT id, name, tag, repo_url, repo_path, image_path, created_at FROM images WHERE id = ?`

	err := r.db.Get(&image, query, id)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return model.Image{}, ErrImageNotFound
		}
		return model.Image{}, fmt.Errorf("failed to get image by id: %w", err)
	}

	return image, nil
}

// GetByName retrieves an image by its name.
func (r *ImageRepo) GetByName(name string) (model.Image, error) {
	var image model.Image
	query := `SELECT id, name, tag, repo_url, repo_path, image_path, created_at FROM images WHERE name = ?`

	err := r.db.Get(&image, query, name)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return model.Image{}, ErrImageNotFound
		}
		return model.Image{}, fmt.Errorf("failed to get image by name: %w", err)
	}

	return image, nil
}
