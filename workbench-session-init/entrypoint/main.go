package main

import (
	"bufio"
	"fmt"
	"io"
	"io/fs"
	"os"
	"path/filepath"
	"time"
)

const (
	sourceDir = "/opt/session-components"
	targetDir = "/mnt/init"
)

var (
	// Read the PWB_SESSION_TYPE environment variable
	sessionType = os.Getenv("PWB_SESSION_TYPE")

	// List of dependencies common to all session types
	commonDeps = []string{
		"bin/git-credential-pwb",
		"bin/focal",
		"bin/jammy",
		"bin/noble",
		"bin/opensuse15",
		"bin/postback",
		"bin/pwb-supervisor",
		"bin/quarto",
		"bin/r-ldpath",
		"bin/rhel8",
		"bin/rhel9",
		"R",
		"resources",
		"www",
		"www-symbolmaps",
	}

	// Map of session-specific dependencies
	sessionDeps = map[string][]string{
		"jupyter": {
			"bin/jupyter-session-run",
			"bin/node",
			"extras",
		},
		"positron": {
			"bin/positron-server",
			"bin/positron-session-run",
			"extras",
		},
		"rstudio": {
			"bin/node",
			"bin/rsession-run",
		},
		"vscode": {
			"bin/pwb-code-server",
			"bin/vscode-session-run",
			"extras",
		},
	}
)

func main() {
	if sessionType == "" {
		fmt.Println("PWB_SESSION_TYPE environment variable is not set")
		os.Exit(1)
	}

	programStart := time.Now()
	defer func() {
		elapsed := time.Since(programStart)
		fmt.Printf("Program took %s\n", elapsed)
	}()

	filesToCopy, err := getFilesToCopy(sessionType)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	err = validateTargetDir(targetDir)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	fmt.Printf("Copying files from %s to %s\n", sourceDir, targetDir)
	start := time.Now()
	for _, file := range filesToCopy {
		srcPath := filepath.Join(sourceDir, file)
		dstPath := filepath.Join(targetDir, file)
		err := copy(srcPath, dstPath)
		if err != nil {
			fmt.Printf("Error copying %s: %v\n", file, err)
			os.Exit(1)
		}
	}

	elapsed := time.Since(start)
	fmt.Printf("Copy operation took %s\n", elapsed)
}

// getFilesToCopy returns the list of files to copy based on the session type.
func getFilesToCopy(sessionType string) ([]string, error) {
	files := commonDeps
	if deps, ok := sessionDeps[sessionType]; ok {
		files = append(files, deps...)
	} else {
		return nil, fmt.Errorf("unknown session type: %s", sessionType)
	}
	return files, nil
}

// validateTargetDir checks if the target directory exists and is empty.
func validateTargetDir(targetDir string) error {
	if _, err := os.Stat(targetDir); os.IsNotExist(err) {
		return fmt.Errorf("cannot find the copy target %s", targetDir)
	}

	isEmpty, err := isDirEmpty(targetDir)
	if err != nil {
		return fmt.Errorf("error checking if target directory is empty: %v", err)
	}
	if !isEmpty {
		return fmt.Errorf("target directory %s is not empty", targetDir)
	}

	return nil
}

// isDirEmpty checks if a directory is empty.
func isDirEmpty(dir string) (bool, error) {
	f, err := os.Open(dir)
	if err != nil {
		return false, err
	}
	defer f.Close()

	_, err = f.ReadDir(1)
	if err == io.EOF {
		return true, nil
	}
	return false, err
}

// copy copies a file or directory from src to dst.
// If src is a directory, it copies the directory recursively.
func copy(src, dst string) error {
	info, err := os.Stat(src)
	if err != nil {
		return fmt.Errorf("error getting file info for %s: %v", src, err)
	}

	if info.IsDir() {
		return copyDir(src, dst, info)
	}
	return copyFile(src, dst, info)
}

// copyDir copies a directory recursively from src to dst.
// It creates the destination directory if it doesn't exist.
func copyDir(src, dst string, info fs.FileInfo) error {
	/* 	cmd := exec.Command("cp", "--recursive", src, dst)
	   	var stdout, stderr bytes.Buffer
	   	cmd.Stdout = &stdout
	   	cmd.Stderr = &stderr
	   	err := cmd.Run()
	   	if err != nil {
	   		return fmt.Errorf("error copying directory %s to %s: %v\n%s", src, dst, err, stderr.String())
	   	} */

	err := os.MkdirAll(dst, info.Mode())
	if err != nil {
		return fmt.Errorf("error creating directory %s: %v", dst, err)
	}

	entries, err := os.ReadDir(src)
	if err != nil {
		return fmt.Errorf("error reading source directory %s: %v", src, err)
	}

	for _, entry := range entries {
		srcPath := filepath.Join(src, entry.Name())
		dstPath := filepath.Join(dst, entry.Name())
		info, err := entry.Info()
		if err != nil {
			return fmt.Errorf("error getting info for %s: %v", srcPath, err)
		}

		if entry.IsDir() {
			err = copyDir(srcPath, dstPath, info)
			if err != nil {
				return err
			}
		} else {
			err = copyFile(srcPath, dstPath, info)
			if err != nil {
				return err
			}
		}
	}
	return nil
}

// copyFile copies a file from src to dst.
// It creates the destination directory if it doesn't exist.
func copyFile(src, dst string, info fs.FileInfo) error {
	sourceFile, err := os.Open(src)
	if err != nil {
		return fmt.Errorf("error opening source file %s: %v", src, err)
	}
	defer sourceFile.Close()

	destDir := filepath.Dir(dst)
	err = os.MkdirAll(destDir, os.ModePerm)
	if err != nil {
		return fmt.Errorf("error creating parent directory %s: %v", destDir, err)
	}

	destFile, err := os.Create(dst)
	if err != nil {
		return fmt.Errorf("error creating destination file %s: %v", dst, err)
	}
	defer destFile.Close()

	buf := bufio.NewReader(sourceFile)
	_, err = io.Copy(destFile, buf)
	if err != nil {
		return fmt.Errorf("error copying file %s to %s: %v", src, dst, err)
	}

	return os.Chmod(dst, info.Mode())
}
