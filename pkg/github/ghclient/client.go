package ghclient

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os/exec"
	"strings"
	"time"
)

// RepoInfo contains metadata about a GitHub repository from the API.
type RepoInfo struct {
	Name  string `json:"name"`
	Owner struct {
		Login string `json:"login"`
	} `json:"owner"`
	CloneURL string `json:"clone_url"`
	HTMLURL  string `json:"html_url"`
}

// Client handles HTTP requests to the GitHub API.
type Client struct {
	httpClient *http.Client
	baseURL    string
}

// NewClient creates a new GitHub API client.
func NewClient() *Client {
	return &Client{
		httpClient: &http.Client{
			Timeout: 30 * time.Second,
		},
		baseURL: "https://api.github.com",
	}
}

// GetRepoInfo fetches repository information from GitHub API.
// The url parameter should be a GitHub repository URL (e.g., github.com/owner/repo).
func (c *Client) GetRepoInfo(url string) (RepoInfo, error) {
	owner, repo, err := parseGithubURL(url)
	if err != nil {
		return RepoInfo{}, err
	}

	apiURL := fmt.Sprintf("%s/repos/%s/%s", c.baseURL, owner, repo)

	req, err := http.NewRequest(http.MethodGet, apiURL, nil)
	if err != nil {
		return RepoInfo{}, fmt.Errorf("failed to create request: %w", err)
	}

	req.Header.Set("Accept", "application/vnd.github+json")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return RepoInfo{}, fmt.Errorf("failed to fetch repo info: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return RepoInfo{}, fmt.Errorf("github api returned status %d", resp.StatusCode)
	}

	var info RepoInfo
	if err := json.NewDecoder(resp.Body).Decode(&info); err != nil {
		return RepoInfo{}, fmt.Errorf("failed to decode response: %w", err)
	}

	return info, nil
}

// CloneRepo clones a GitHub repository to the specified destination path.
func (c *Client) CloneRepo(cloneURL string, destPath string) error {
	cmd := exec.Command("git", "clone", cloneURL, destPath)
	if output, err := cmd.CombinedOutput(); err != nil {
		return fmt.Errorf("git clone failed: %s: %w", string(output), err)
	}
	return nil
}

// parseGithubURL extracts owner and repo name from a GitHub URL.
// Supports formats:
//   - github.com/owner/repo
//   - https://github.com/owner/repo
//   - https://github.com/owner/repo.git
func parseGithubURL(url string) (owner, repo string, err error) {
	// Remove protocol prefix
	url = strings.TrimPrefix(url, "https://")
	url = strings.TrimPrefix(url, "http://")

	// Remove github.com prefix
	url = strings.TrimPrefix(url, "github.com/")

	// Remove .git suffix
	url = strings.TrimSuffix(url, ".git")

	// Remove trailing slash
	url = strings.TrimSuffix(url, "/")

	parts := strings.Split(url, "/")
	if len(parts) < 2 {
		return "", "", fmt.Errorf("invalid github url: expected owner/repo format")
	}

	return parts[0], parts[1], nil
}
