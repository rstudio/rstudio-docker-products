package main

import (
	"fmt"
	"io"
	"os"
	"path/filepath"
	"time"

	cp "github.com/otiai10/copy"
)

const (
	sourceDir = "/opt/session-components"
	targetDir = "/mnt/init"
)

var (
	// Read the PWB_SESSION_TYPE environment variable
	sessionType = os.Getenv("PWB_SESSION_TYPE")

	// Set the copy options.
	// Preserve permissions, times, and owner.
	opt = cp.Options{
		PermissionControl: cp.PerservePermission,
		PreserveTimes:     true,
		PreserveOwner:     true,
		NumOfWorkers:      20,
	}

	// List of dependencies common to all environments
	commonDeps = []string{
		"bin/pwb-supervisor",
	}

	// List of dependencies common to all session types
	commonSessionDeps = append([]string{
		"bin/git-credential-pwb",
		"bin/focal",
		"bin/jammy",
		"bin/noble",
		"bin/opensuse15",
		"bin/postback",
		"bin/quarto",
		"bin/r-ldpath",
		"bin/rhel8",
		"bin/rhel9",
		"bin/shared-run",
		"R",
		"resources",
		"www",
		"www-symbolmaps",
	}, commonDeps...)

	// Map of session-specific dependencies
	sessionDeps = map[string][]string{
		"jupyter": append([]string{
			"bin/jupyter-session-run",
			"extras",
		}, commonSessionDeps...),
		"positron": append([]string{
			"bin/positron-server",
			"bin/positron-session-run",
			"extras",
		}, commonSessionDeps...),
		"rstudio": append([]string{
			"bin/rsession-run",
		}, commonSessionDeps...),
		"vscode": append([]string{
			"bin/pwb-code-server",
			"bin/vscode-session-run",
			"extras",
		}, commonSessionDeps...),
		"adhoc": commonDeps,
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

	err = copyFiles(sourceDir, targetDir, filesToCopy)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	fmt.Println("Copy operation completed.")
}

// getFilesToCopy returns the list of files to copy based on the session type.
func getFilesToCopy(sessionType string) ([]string, error) {
	if deps, ok := sessionDeps[sessionType]; ok {
		return deps, nil
	} else {
		return nil, fmt.Errorf("unknown session type: %s", sessionType)
	}
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

// copyFiles copies the files from the source directory to the target directory.
// It uses the otiai10/copy package to copy files, with options to preserve
// permissions, times, and owner.
func copyFiles(src, dst string, filesToCopy []string) error {
	fmt.Printf("Copying files from %s to %s\n", src, dst)
	start := time.Now()

	for _, file := range filesToCopy {
		srcPath := filepath.Join(src, file)
		dstPath := filepath.Join(dst, file)
		err := cp.Copy(srcPath, dstPath, opt)
		if err != nil {
			return fmt.Errorf("error copying %s: %v", srcPath, err)
		}
	}

	elapsed := time.Since(start)
	fmt.Printf("Copy operation took %s\n", elapsed)

	return nil
}
