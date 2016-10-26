QEMU plugins
============

This is an image containing a prebuilt QEMU with plugins support
(qemu-plugins) for architectures x86_65/aarch64 and arm as well as sysroots
for arm and aarch64 as provided by Linaro.

It can be used to directly execute qemu-plugins in user mode emulation for
 instance on one of the architectures mentionned above.

Run
---

Run the image with:

    $ docker pull guillon/qemu-plugins
    $ docker run -it guillon/qemu-plugins
    root@container:~$  qemu-aarch64 --version
    qemu-aarch64 version 2.6.0-stm-5.1.0, Copyright (c) 2003-2008 Fabrice Bellard
    root@container:~$  ls -d /opt/* # available sysroots for aarch64 and arm
    /opt/sysroot-linaro-glibc-gcc5.3-2016.02-aarch64-linux-gnu
    /opt/sysroot-linaro-glibc-gcc5.3-2016.02-arm-linux-gnueabihf

Note that the provided sysroots can be used for running arm or aarch64
programs which are dynamically linked. In this case call qemu with the
`-L <sysroot>` option as in:

    qemu-aarch64 -L /opt/sysroot-linaro-glibc-gcc5.3-2016.02-aarch64-linux-gnu <aarch64_exe>
    or
    qemu-arm -L /opt/sysroot-linaro-glibc-gcc5.3-2016.02-arm-linux-gnueabihf <arm_exe>

Use Image
---------

From this image, one may directly execute qemu-x86_64, qemu-arm or
qemu-aarch64 on a compiled Linux program for one of these architectures.

For instance, assuming a `hello.a64` program compiled for aarch64-linux in the
current working dir, one may emulate it with this command:

    $ docker run -v $PWD:$PWD:ro -w $PWD guillon/qemu-plugins \
      qemu-aarch64 -L /opt/sysroot-linaro-glibc-gcc5.3-2016.02-aarch64-linux-gnu \
      ./hello.a64
    Hello world!

Following are some examples of usage of several qemu-plugins (activated with
the `-tcg-plugin <plugin_name>`) option.

Get total executed instruction count:

    $ docker run -v $PWD:$PWD:ro -w $PWD guillon/qemu-plugins qemu-aarch64 \
      -L /opt/sysroot-linaro-glibc-gcc5.3-2016.02-aarch64-linux-gnu \
      -tcg-plugin icount ./hello.a64
    Hello world!
    ./hello.a64 (1): number of executed instructions on CPU #0 = 77755

Dump instructions trace:

    $ docker run -v $PWD:$PWD:ro -w $PWD guillon/qemu-plugins qemu-aarch64 \
      -L /opt/sysroot-linaro-glibc-gcc5.3-2016.02-aarch64-linux-gnu \
      -tcg-plugin dyntrace hello.a64 2>hello.dyntrace.txt
    $ head hello.dyntrace.txt
    0x4000801d80:    mov     x0, sp  // e0 03 00 91
    0x4000801d84:    bl      #0x4000805368   // 79 0d 00 94
    0x4000805368:    sub     sp, sp, #0x490  // ff 43 12 d1
    0x400080536c:    stp     x29, x30, [sp, #-0x60]!         // fd 7b ba a9
    0x4000805370:    mov     x29, sp         // fd 03 00 91
    0x4000805374:    stp     x27, x28, [sp, #0x50]   // fb 73 05 a9
    0x4000805378:    add     x27, x29, #0x88         // bb 23 02 91
    0x400080537c:    add     x1, x27, #0x2a0         // 61 83 0a 91
    0x4000805380:    stp     x19, x20, [sp, #0x10]   // f3 53 01 a9
    0x4000805384:    str     x0, [x29, #0x78]        // a0 3f 00 f9

Dump execution blocks PC trace:

    $ docker run -v $PWD:$PWD:ro -w $PWD guillon/qemu-plugins qemu-aarch64 \
      -L /opt/sysroot-linaro-glibc-gcc5.3-2016.02-aarch64-linux-gnu \
      -tcg-plugin trace hello.a64 2>hello.trace.txt
    $ head -5 hello.trace.txt
    ./hello.a64 1 1: CPU #0 - 0x0000004000801d80 [8]: 2 instruction(s) in
        '<unknown>:<unknown>'
    ./hello.a64 1 1: CPU #0 - 0x0000004000805368 [60]: 15 instruction(s) in
        '/lib/ld-linux-aarch64.so.1:_dl_start'
    ./hello.a64 1 1: CPU #0 - 0x0000004000805398 [12]: 3 instruction(s) in
        '/lib/ld-linux-aarch64.so.1:_dl_start'
    ./hello.a64 1 1: CPU #0 - 0x0000004000805398 [12]: 3 instruction(s) in
        '/lib/ld-linux-aarch64.so.1:_dl_start'
    ./hello.a64 1 1: CPU #0 - 0x0000004000805398 [12]: 3 instruction(s) in
        '/lib/ld-linux-aarch64.so.1:_dl_start'

Dump summary of executed instruction mnemonics:

    $ docker run -v $PWD:$PWD:ro -w $PWD guillon/qemu-plugins qemu-aarch64 \
      -L /opt/sysroot-linaro-glibc-gcc5.3-2016.02-aarch64-linux-gnu \
      -tcg-plugin dyncount hello.a64 2>hello.dyncount.yml
    $ head hello.dyncount.yml
    mnemonics_count:
      add: 8765
      addp: 19
      adr: 15
      adrp: 743
      and: 2261
      ands: 129
      asr: 231
      b: 732

Dump function trace (call entry/exit and stack frames):

    $ docker run -v $PWD:$PWD:ro -w $PWD guillon/qemu-plugins qemu-aarch64 \
      -L /opt/sysroot-linaro-glibc-gcc5.3-2016.02-aarch64-linux-gnu \
      -tcg-plugin ftrace hello.a64 2>hello.ftrace.yml
    $ head -8 hello.ftrace.yml
    - call_entry: { tid: 1, id: 0, depth: 0, sym_name: "", file_name: "" }
      frames:
        -  { id: 0, depth: 0, sym_name: "", file_name: "", sym_addr: 0x4000801d80,
             stack_ptr: 0x4000800e20, return_addr: 0x0 }
    - call_entry: { tid: 1, id: 1, depth: 1, sym_name: "_dl_start",
                    file_name: "/lib/ld-linux-aarch64.so.1" }
      frames:
        -  { id: 0, depth: 0, sym_name: "", file_name: "", sym_addr: 0x4000801d80,
             stack_ptr: 0x4000800e20, return_addr: 0x0 }
        -  { id: 1, depth: 1, sym_name: "_dl_start",
             file_name: "/lib/ld-linux-aarch64.so.1", sym_addr: 0x4000805368,
             stack_ptr: 0x4000800e20, return_addr: 0x4000801d88 }
    - call_entry: { tid: 1, id: 2, depth: 2, sym_name: "_dl_start_final",
                    file_name: "/lib/ld-linux-aarch64.so.1" }


Modify Image
------------

The image sources are located at https://github.com/guillon/docker-qemu-plugins, actually an automated Docker hub build is setup and the images are available at https://hub.docker.com/r/guillon/qemu-plugins/ when this repo is modified.

In order to rebuild the image locally, extract sources and execute the `./build.sh` script which build the Docker image locally under the name `guillon/dev-qemu-dev`:

    $ git clone https://github.com/guillon/docker-qemu-plugins
    $ cd docker-qemu-plugins
    $ ./build.sh
    $ docker run -it guillon/dev-qemu-plugins
    ...


References
----------

Ref QEMU repository: https://github.com/qemu/qemu

Ref qemu-plugins repository: https://github.com/guillon/qemu-plugins

Ref to Linaro gcc/sysroots downloads: http://www.linaro.org/downloads

Ref docker-qemu-plugins repository: https://github.com/guillon/docker-qemu-plugins

Ref docker hub prebuilt images: https://hub.docker.com/r/guillon/qemu-plugins/
