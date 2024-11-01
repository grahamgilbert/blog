+++
date = 2020-06-01T07:00:00Z
lastmod = 2020-06-01T07:00:00Z
title = "Go for endpoint management"
+++

For Mac admins using Python to perform scripting duties, the impending departure of Python 2 from the default install of macOS should be encouraging them to look at alternatives.

One option that is probably the easiest, is shipping your own installation of Python 3. This however isn't without it's drawbacks. You need to deploy and maintain an entire Python 3 runtime. Tools such as Greg Neagle's [Relocatable Python](https://github.com/gregneagle/relocatable-python) have made this easier, but it still remains a dependency for any tool you write. Shell and zsh are options for very basic scripts. What about for scripts that need a more advanced language?

If you are just working on macOS, Swift is a very good option. It has access to system frameworks, and is a single binary. This means that your dependencies are bundled up with your script in a single executable.

But what if you are working cross platform? [Go](https://golang.org/) support macOS, Windows and Linux. Go doesn't offer an easy way to access the native macOS API's, so if you desperately need to access those, Go might not be the best option. But but for many Endpoint Administration tasks, Go is an excellent option that, like Swift, compiles to a single binary, and on macOS is able to be signed and notarized.

## The problem

Let's take a common problem in large, cross platform environments - having two or three sets of instructions for helpdesk to follow for your various operating systems. Let's say we want to build a tool that will download and install OS updates for both macOS and Windows, so we only need to train our helpdesk team on one tool.

Just starting out with Go? I definitely suggest you run through a few parts of the [Go Tour](https://tour.golang.org/welcome/1) to familiarize yourself with the differences between Go and languages you have used before.

## Let's get started

First we need to make somewhere for our code to live and initialize our go.mod file. The name of your project is usually the name of the repo in which it will live (it doesn't need to be the public Github, it can just as easily bo an internal source control system). If you haven't already, you need to install [Go](https://golang.org/dl/). I also suggest setting up your editor for effective Go development - [my setup is outlined](https://grahamgilbert.com/blog/2020/05/28/my-perfect-vs-code-setup/) here.

```bash
mkdir -p ~/src/osupdate
cd ~/src/osupdate
go mod init github.com/grahamgilbert/osupdate
```

And let's start our basic app. Create a file called `main.go`

```go
// main.go
package main

func main() {

}
```

Nothing too exiting there. Let's add in a function to check for OS updates on macOS.

```go
// main.go
package main

import (
 "fmt"
 "log"
 "os/exec"
)

func main() {

    err = downloadUpdates()
 if err != nil {
  log.Fatal(err)
 }

}

func downloadUpdates() error {
 cmd := exec.Command("/usr/sbin/softwareupdate", "-dla")

 out, err := cmd.CombinedOutput()
 if err != nil {
  fmt.Print(string(out))
  return err
 }
 fmt.Print(string(out))

 return nil
}

```

## But what about other platforms?

That's all well and fine, but aren't we supposed to be handling Windows devices as well? Fortunately Go can tell us what platform we're running on very easily.

```go
// more stuff above
func downloadUpdates() error {
 cmd := exec.Command("/usr/sbin/softwareupdate", "-dla")
 if runtime.GOOS == "windows" {
  p := filepath.FromSlash("C:/Windows/system32/wuauclt.exe")
  cmd = exec.Command(p, "/detectnow")
 }

 out, err := cmd.CombinedOutput()
 if err != nil {
  fmt.Print(string(out))
  return err
 }
 fmt.Print(string(out))

 return nil
}
```

The functions to ensure we are running on supported platforms and to install and reboot the device are very similar once we've got the above function down. Our final program will look like this:

```go
// main.go
package main

import (
 "errors"
 "fmt"
 "log"
 "os/exec"
 "path/filepath"
 "runtime"
)

func main() {

 err := checkForUnsupportedPlatform()
 if err != nil {
  log.Fatal(err)
 }

 err = downloadUpdates()
 if err != nil {
  log.Fatal(err)
 }

 err = installUpdates()
 if err != nil {

  log.Fatal(err)
 }

}

func checkForUnsupportedPlatform() error {
 if runtime.GOOS != "darwin" && runtime.GOOS != "windows" {
  err := errors.New("Unsupported platform")
  return err
 }

 return nil
}

func downloadUpdates() error {
 cmd := exec.Command("/usr/sbin/softwareupdate", "-dla")
 if runtime.GOOS == "windows" {
  p := filepath.FromSlash("C:/Windows/system32/wuauclt.exe")
  cmd = exec.Command(p, "/detectnow")
 }

 out, err := cmd.CombinedOutput()
 if err != nil {
  fmt.Print(string(out))
  return err
 }
 fmt.Print(string(out))

 return nil
}

func installUpdates() error {
 cmd := exec.Command("/usr/sbin/softwareupdate", "-dia", "--restart")
 if runtime.GOOS == "windows" {
  p := filepath.FromSlash("C:/Windows/system32/wuauclt.exe")
  cmd = exec.Command(p, "/updatenow")
 }

 out, err := cmd.CombinedOutput()
 if err != nil {
  fmt.Print(string(out))
  return err
 }
 fmt.Print(string(out))

 return nil
}
```

## Building

By default Go will build for the platform you are running. Fortunately we just need to set the `GOOS` environment variable whilst building to get a binary for other platforms.

```bash
GOOS=darwin go build -o build/darwin/osupdate
GOOS=windows go build -o build/windows/osupdate.exe
```

## Conclusion

We've seen here that we can use Go to produce a single binary for multiple platforms, which will make it incredibly easy to distribute, whilst maintaining a consistent interface for our helpdesk to use. This code has many places where it could be improved - in a future post I'll cover how we can use Go's multi-platform build capabilities more effectively, and re-organize the code to make it easier to add support for other platforms that we may manage, such as Linux. The final code, along with a build script can be found on my [Github](https://github.com/grahamgilbert/osupdate).
