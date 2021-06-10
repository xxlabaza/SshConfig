## Legal

By submitting a pull request, you represent that you have the right to license your contribution to the community, and agree by submitting the patch that your contributions are licensed under the Apache 2.0 [license](./LICENSE.txt).

## How to submit a bug report

Please ensure to specify the following:

* SshConfig commit hash
* Contextual information (e.g. what you were trying to achieve with SshConfig)
* Simplest possible steps to reproduce
  * More complex the steps are, lower the priority will be.
  * A pull request with failing test case is preferred, but it's just fine to paste the test case into the issue description.
* Anything that might be relevant in your opinion, such as:
  * Swift version or the output of `swift --version`
  * OS version and the output of `uname -a`

### Example

```
SshConfig commit hash: 22ec043dc9d24bb011b47ece4f9ee97ee5be2757

Context:
While working with SshConfig in my app, I noticed
that a resolve method is leaked per call.

Steps to reproduce:
1. ...
2. ...
3. ...
4. ...

$ swift --version
Swift version 5.4 (swift-5.4-RELEASE)
Target: x86_64-unknown-linux-gnu

Operating system: Ubuntu Linux 16.04 64-bit

$ uname -a
Linux beefy.machine 4.4.0-101-generic #124-Ubuntu SMP Fri Nov 10 18:29:59 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux

I have a very long SSH config there.
```

## Writing a Patch

A good SshConfig patch is:

1. Concise, and contains as few changes as needed to achieve the end result.
2. Tested, ensuring that any tests provided failed before the patch and pass after it.
3. Documented, adding API documentation as needed to cover new functions and properties.
4. Accompanied by a great commit message, using my commit message template.

### Commit Message Template

I require that your commit messages match my template. The easiest way to do that is to get git to help you by explicitly using the template. To do that, `cd` to the root of my repository and run:

    git config commit.template dev/git.commit.template

The default policy for taking contributions is “Squash and Merge” - because of this the commit message format rule above applies to the PR rather than every commit contained within it.

### Make sure Tests work on Linux

SshConfig uses XCTest to run tests on both macOS and Linux. While the macOS version of XCTest is able to use the Objective-C runtime to discover tests at execution time, the Linux version is not (prior to swift 5.1).
For this reason, whenever you add new tests **you have to add it to allTests variable manually** by running the command `swift test --generate-linuxmain`.

### Make sure your patch works for all supported versions of swift

Currently all versions of swift >= 5.1 are supported. The CI will do this for you. You can use the following command if you wish to check locally:

**for M1**:

```bash
$> docker run -it \
    -v <path_to_SshConfig_root_folder>:/popa \
    wlisac/aarch64-swift:5.1-build \
    /bin/bash -c "cd /popa; swift test && exit"

...
```

**for Intel**:

```bash
$> docker run -it \
    -v <path_to_SshConfig_root_folder>:/popa \
    swift:5.1-slim \
    /bin/bash -c "cd /popa; swift test && exit"

...
```

### Formatting

Try to keep your lines less than 120 characters long so github can correctly display your changes.

### Extensibility

Try to make sure your code is robust to future extensions.

## How to contribute your work

Please open a pull request at https://github.com/xxlabaza/SshConfig. Make sure the CI passes, and then wait for code review.

After review you may be asked to make changes.  When you are ready, use the request re-review feature of github or mention the reviewers by name in a comment.
