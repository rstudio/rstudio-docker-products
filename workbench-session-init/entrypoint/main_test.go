package main

import (
	"os"
	"path/filepath"
	"reflect"
	"syscall"
	"testing"
)

func TestGetFilesToCopy(t *testing.T) {
	tests := []struct {
		sessionType string
		expected    []string
		expectError bool
	}{
		{
			sessionType: "jupyter",
			expected:    sessionDeps["jupyter"],
			expectError: false,
		},
		{
			sessionType: "positron",
			expected:    sessionDeps["positron"],
			expectError: false,
		},
		{
			sessionType: "rstudio",
			expected:    sessionDeps["rstudio"],
			expectError: false,
		},
		{
			sessionType: "vscode",
			expected:    sessionDeps["vscode"],
			expectError: false,
		},
		{
			sessionType: "vscode",
			expected:    sessionDeps["vscode"],
			expectError: false,
		},
		{
			sessionType: "adhoc",
			expected:    commonDeps,
			expectError: false,
		},
		{
			sessionType: "unknown",
			expected:    nil,
			expectError: true,
		},
	}

	for _, test := range tests {
		t.Run(test.sessionType, func(t *testing.T) {
			files, err := getFilesToCopy(test.sessionType)
			if test.expectError {
				if err == nil {
					t.Errorf("Expected error for session type %s, but got none", test.sessionType)
				}
			} else {
				if err != nil {
					t.Errorf("Did not expect error for session type %s, but got: %v", test.sessionType, err)
				}
				if !reflect.DeepEqual(files, test.expected) {
					t.Errorf("Files do not match for session type %s. Expected: %v, Got: %v", test.sessionType, test.expected, files)
				}
			}
		})
	}
}

func TestCopy(t *testing.T) {
	// Create temporary source and destination directories
	srcDir, err := os.MkdirTemp("", "src")
	if err != nil {
		t.Fatalf("Failed to create temporary source directory: %v", err)
	}
	defer os.RemoveAll(srcDir)

	dstDir, err := os.MkdirTemp("", "dst")
	if err != nil {
		t.Fatalf("Failed to create temporary destination directory: %v", err)
	}
	defer os.RemoveAll(dstDir)

	// Create a sample directory structure in the source directory that looks like:
	// srcDir
	// ├── file1.txt
	// └── subdir1
	//     ├── file2.txt
	//     └── subdir2
	//         └── file3.txt
	// |__ subdir3
	err = os.MkdirAll(filepath.Join(srcDir, "subdir1"), 0755)
	if err != nil {
		t.Fatalf("Failed to create subdir1: %v", err)
	}
	err = os.WriteFile(filepath.Join(srcDir, "file1.txt"), []byte("file1 content"), 0644)
	if err != nil {
		t.Fatalf("Failed to create file1.txt: %v", err)
	}
	err = os.WriteFile(filepath.Join(srcDir, "subdir1", "file2.txt"), []byte("file2 content"), 0600)
	if err != nil {
		t.Fatalf("Failed to create file2.txt: %v", err)
	}
	err = os.MkdirAll(filepath.Join(srcDir, "subdir1", "subdir2"), 0755)
	if err != nil {
		t.Fatalf("Failed to create subdir2: %v", err)
	}
	err = os.WriteFile(filepath.Join(srcDir, "subdir1", "subdir2", "file3.txt"), []byte("file3 content"), 0644)
	if err != nil {
		t.Fatalf("Failed to create file3.txt: %v", err)
	}
	err = os.MkdirAll(filepath.Join(srcDir, "subdir3"), 0755)
	if err != nil {
		t.Fatalf("Failed to create subdir3: %v", err)
	}

	// Copy the directory structure from source to destination
	// exclude subdir3
	filesToCopy := []string{
		"file1.txt",
		"subdir1",
	}
	err = copyFiles(srcDir, dstDir, filesToCopy)
	if err != nil {
		t.Fatalf("Failed to copy files: %v", err)
	}

	// Verify that the directory structure and files are correctly copied
	verifyFile(t, filepath.Join(dstDir, "file1.txt"), 0644, os.Getuid(), os.Getgid())
	verifyFile(t, filepath.Join(dstDir, "subdir1", "file2.txt"), 0600, os.Getuid(), os.Getgid())
	verifyFile(t, filepath.Join(dstDir, "subdir1", "subdir2", "file3.txt"), 0644, os.Getuid(), os.Getgid())
	// Verify that subdir3 is not copied
	if _, err := os.Stat(filepath.Join(dstDir, "subdir3")); !os.IsNotExist(err) {
		t.Errorf("Directory subdir3 should not have been copied")
	}
}

func verifyFile(t *testing.T, path string, mode os.FileMode, uid, gid int) {
	info, err := os.Stat(path)
	if err != nil {
		t.Fatalf("Failed to stat file %s: %v", path, err)
	}

	if info.Mode() != mode {
		t.Errorf("File %s has incorrect permissions: got %v, want %v", path, info.Mode(), mode)
	}

	stat, ok := info.Sys().(*syscall.Stat_t)
	if !ok {
		t.Fatalf("Failed to get file ownership for %s", path)
	}

	if int(stat.Uid) != uid || int(stat.Gid) != gid {
		t.Errorf("File %s has incorrect ownership: got %d:%d, want %d:%d", path, stat.Uid, stat.Gid, uid, gid)
	}
}
