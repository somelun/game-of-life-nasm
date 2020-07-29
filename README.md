
**MacOS x64 NASM implementation of [Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life)**

![](https://github.com/somelun/game-of-life-nasm/blob/master/glider.gif)

This is *just for fun* implementation with looped borders. I have plans for future optimizations and refactoring, also add "read initial pattern from file" and bool flag for "use looped borders". Maybe I would be able to implement simple ASCII draw insead of just . and *

Some useful links:<br>
[NASM Tutorial](https://cs.lmu.edu/~ray/notes/nasmtutorial/)<br>
[x86_64 NASM Assembly Quick Reference](https://www.cs.uaf.edu/2017/fall/cs301/reference/x86_64.html)<br>
[Making system calls from Assembly in Mac OS X](https://filippo.io/making-system-calls-from-assembly-in-mac-os-x/)<br>

List of Mac OS syscalls available at the path:<br>
*/Library/Developer/CommandLineTools/SDKs/MacOSX10.15.sdk/usr/include/sys/syscall.h*

Also I used [PyvesB'](https://github.com/PyvesB) [project](https://github.com/PyvesB/asm-game-of-life) as a good example.
