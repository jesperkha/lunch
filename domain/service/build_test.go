package service

import (
	"errors"
	"lunch/domain/model"
	"lunch/domain/port/mocks"
	"path/filepath"
	"testing"

	"go.uber.org/mock/gomock"
)

func TestBuildService_PullAndBuild_Success(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	mockGithubRepo := mocks.NewMockGithubRepository(ctrl)
	mockDockerBuilder := mocks.NewMockDockerBuilder(ctrl)

	service := NewBuildService(mockGithubRepo, mockDockerBuilder)

	url := "https://github.com/example/repo"
	output := "/tmp/output"
	repoPath := filepath.Join(output, "repo")
	dockerfilePath := filepath.Join(repoPath, "Dockerfile")

	expectedRepo := model.GithubRepo{
		Name:          "repo",
		URL:           url,
		Creator:       "example",
		HasDockerfile: true,
		LocalPath:     repoPath,
	}

	mockGithubRepo.EXPECT().
		PullGithubRepo(url, output).
		Return(expectedRepo, nil)

	mockDockerBuilder.EXPECT().
		BuildImage(dockerfilePath, repoPath).
		Return(nil)

	err := service.PullAndBuild(url, output)
	if err != nil {
		t.Errorf("expected no error, got %v", err)
	}
}

func TestBuildService_PullAndBuild_PullError(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	mockGithubRepo := mocks.NewMockGithubRepository(ctrl)
	mockDockerBuilder := mocks.NewMockDockerBuilder(ctrl)

	service := NewBuildService(mockGithubRepo, mockDockerBuilder)

	url := "https://github.com/example/repo"
	output := "/tmp/output"
	pullError := errors.New("failed to clone repository")

	mockGithubRepo.EXPECT().
		PullGithubRepo(url, output).
		Return(model.GithubRepo{}, pullError)

	err := service.PullAndBuild(url, output)
	if err == nil {
		t.Error("expected error, got nil")
	}
}

func TestBuildService_PullAndBuild_NoDockerfile(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	mockGithubRepo := mocks.NewMockGithubRepository(ctrl)
	mockDockerBuilder := mocks.NewMockDockerBuilder(ctrl)

	service := NewBuildService(mockGithubRepo, mockDockerBuilder)

	url := "https://github.com/example/repo"
	output := "/tmp/output"
	repoPath := filepath.Join(output, "repo")

	expectedRepo := model.GithubRepo{
		Name:          "repo",
		URL:           url,
		Creator:       "example",
		HasDockerfile: false,
		LocalPath:     repoPath,
	}

	mockGithubRepo.EXPECT().
		PullGithubRepo(url, output).
		Return(expectedRepo, nil)

	err := service.PullAndBuild(url, output)
	if err == nil {
		t.Error("expected error for missing Dockerfile, got nil")
	}
}

func TestBuildService_PullAndBuild_BuildError(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	mockGithubRepo := mocks.NewMockGithubRepository(ctrl)
	mockDockerBuilder := mocks.NewMockDockerBuilder(ctrl)

	service := NewBuildService(mockGithubRepo, mockDockerBuilder)

	url := "https://github.com/example/repo"
	output := "/tmp/output"
	repoPath := filepath.Join(output, "repo")
	dockerfilePath := filepath.Join(repoPath, "Dockerfile")
	buildError := errors.New("docker build failed")

	expectedRepo := model.GithubRepo{
		Name:          "repo",
		URL:           url,
		Creator:       "example",
		HasDockerfile: true,
		LocalPath:     repoPath,
	}

	mockGithubRepo.EXPECT().
		PullGithubRepo(url, output).
		Return(expectedRepo, nil)

	mockDockerBuilder.EXPECT().
		BuildImage(dockerfilePath, repoPath).
		Return(buildError)

	err := service.PullAndBuild(url, output)
	if err == nil {
		t.Error("expected error for docker build failure, got nil")
	}
}
