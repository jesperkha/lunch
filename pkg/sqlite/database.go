package sqlite

import (
	"fmt"

	"github.com/jmoiron/sqlx"
	_ "github.com/mattn/go-sqlite3"
)

// Database wraps a sqlx.DB connection for SQLite.
type Database struct {
	*sqlx.DB
}

// NewDatabase creates a new SQLite database connection.
// The dataSourceName is the path to the SQLite database file.
func NewDatabase(dataSourceName string) (*Database, error) {
	db, err := sqlx.Connect("sqlite3", dataSourceName)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to database: %w", err)
	}

	// Enable foreign keys
	if _, err := db.Exec("PRAGMA foreign_keys = ON"); err != nil {
		return nil, fmt.Errorf("failed to enable foreign keys: %w", err)
	}

	return &Database{DB: db}, nil
}

// Close closes the database connection.
func (d *Database) Close() error {
	return d.DB.Close()
}

// Migrate runs database migrations to create necessary tables.
func (d *Database) Migrate() error {
	schema := `
	CREATE TABLE IF NOT EXISTS images (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		name TEXT NOT NULL UNIQUE,
		tag TEXT NOT NULL DEFAULT 'latest',
		repo_url TEXT NOT NULL,
		repo_path TEXT NOT NULL,
		image_path TEXT NOT NULL,
		created_at TEXT NOT NULL DEFAULT (datetime('now'))
	);
	`

	if _, err := d.Exec(schema); err != nil {
		return fmt.Errorf("failed to run migrations: %w", err)
	}

	return nil
}
