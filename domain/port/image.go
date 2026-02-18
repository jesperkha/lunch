package port

import "lunch/domain/model"

// ImageRepo defines the interface for storing and retrieving Docker images.
type ImageRepo interface {
	// New stores a new image and returns its ID.
	New(image model.Image) (id int, err error)

	// GetById retrieves an image by its ID.
	GetById(id int) (model.Image, error)

	// GetByName retrieves an image by its name.
	GetByName(name string) (model.Image, error)
}
