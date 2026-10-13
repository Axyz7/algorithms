#set page(
  paper: "a4",
  margin: (x: 1.8cm, y: 1.8cm),
  footer: context align(center)[#text(size: 8.5pt)[Page #counter(page).display()]]
)
#set text(
  size: 9.5pt,
  font: ("Adwaita Sans", "FreeSans") // Main body font
)

// Set all code & terminal output to JetBrains Mono
#show raw: set text(font: "JetBrains Mono", size: 8.5pt)

// Set math equations to New Computer Modern Math
#show math.equation: set text(font: "New Computer Modern Math")

// --- CODE BLOCK & TERMINAL BOX BORDERS ---
#show raw.where(block: true): block.with(
  stroke: 0.5pt + luma(80),
  inset: 8pt,
  radius: 2pt,
  width: 100%,
  fill: none // 100% white background to save printer ink
)

// --- HEADING STYLING ---
#show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 0.6em)[
  #text(size: 12pt, weight: "bold")[#it.body]
  #v(-0.2em)
  #line(length: 100%, stroke: 0.8pt)
]

#show heading.where(level: 2): it => block(above: 0.8em, below: 0.4em)[
  #text(size: 10pt, weight: "bold")[#it.body]
]

// --- DOCUMENT HEADER ---
#align(center)[
  #text(size: 15pt, weight: "bold")[LAB REPORT 1: BASIC UNIX UTILITY COMMANDS] \
  #v(2pt)
  #text(size: 10pt)[Course: Operating Systems Lab]
]

#v(0.5em)
#grid(
  columns: (1fr, 1fr),
  align: (left, right),
  [
    *Student Name:* Aryan Nautiyal \
    *Roll Number:* 251210015
  ],
  [
    *Date:* #datetime.today().display("[Year]-[Month]-[Day]") \
    *Environment:* Bash / POSIX (Linux x86_64)
  ]
)
#line(length: 100%, stroke: 0.5pt)

// =========================================================================
// PART A: FILE & DIRECTORY OPERATIONS
// =========================================================================
= 1. Experiment 1A: File & Directory Manipulation

== 1.1 Aim & Objective
To demonstrate directory navigation, directory creation, file creation, content inspection, copying, and file removal using POSIX-compliant Unix shell utilities (`pwd`, `mkdir`, `cd`, `ls`, `touch`, `cat`, `cp`, `rm`,etc).

== 1.2 Command Summary & Syntax Analysis
#table(
  columns: (1.2fr, 1.5fr, 3fr),
  align: (left + horizon, left + horizon, left + horizon),
  stroke: none,
  table.hline(stroke: 0.8pt),
  [*Command*], [*Syntax Example*], [*Primary Function / Description*],
  table.hline(stroke: 0.4pt),
  [`pwd`], [`pwd`], [Print the absolute path of the current working directory.],
  [`mkdir`], [`mkdir <dir_name>`], [Create a new directory in the specified path. -p flag to create parent directories too.],
  [`cd`], [`cd <dir_name>`], [Change the current shell working directory.],
  [`ls`], [`ls -la`], [List directory contents, including hidden files (`.`) if using the -la flag which stands for list all, with details.],
  [`touch`], [`touch <file_name>`], [Create an empty file or update access/modification timestamps, unless using the -c(no create) or -h(only symlink, no dereference) flags.],
  [`cat`], [`cat <file_name>`], [Concatenate files and print contents to standard output. Good for small files. Advanced alternatives are "more", "less" or "bat", which have features like moving in forward or backward direction, to read large files.],
  [`cp`], [`cp <src> <dest>`], [Copy files or directories from source to destination.],
  [`mv`], [`mv <src> <dest>`], [Move files or directories from source to destination. Can also be used to rename files.],
  [`head`],[`head -n 5`], [Print the first 10 lines of each FILE to standard output. With "-n" option we can specify the number instead of 10.],
  [`rm`], [`rm <file_name>`], [Remove files or directories from the file system. For directories, we use -r option, which stands for "recursive" and remove all files under listed directory.],
  table.hline(stroke: 0.8pt)
)


== 1.3 Terminal Output
```bash
$ pwd
/home/aryan/unix_lab

$ mkdir exp1_demo && cd exp1_demo

$ touch sample.txt

$ ls -la
total 8
drwxr-xr-x 2 aryan aryan 4096 Jul 28 14:00 .
drwxr-xr-x 3 aryan aryan 4096 Jul 28 13:58 ..
-rw-r--r-- 1 aryan aryan    0 Jul 28 14:00 sample.txt

$ echo "Hello Unix Shell Environment" > sample.txt

$ cat sample.txt
Hello Unix Shell Environment

$ cp sample.txt backup.txt

$ ls -l
total 8
-rw-r--r-- 1 aryan aryan 29 Jul 28 14:02 backup.txt
-rw-r--r-- 1 aryan aryan 29 Jul 28 14:01 sample.txt

$ rm backup.txt && ls -l
total 4
-rw-r--r-- 1 aryan aryan 29 Jul 28 14:01 sample.txt

$ mv sample.txt renamed_file.txt
```

#v(0.5em)

// =========================================================================
// PART B: SYSTEM INFO & PROCESS MANAGEMENT
// =========================================================================
= 2. Experiment 1B: System Information & Process Management

== 2.1 Aim & Objective
To inspect system hardware/kernel attributes (`uname`), clear terminal state (`clear`), read system manual documentation (`man`), and monitor active system processes (`ps`, `top`).

== 2.2 Command Summary & Syntax Analysis
#table(
  columns: (1.2fr, 1.5fr, 3fr),
  align: (left + horizon, left + horizon, left + horizon),
  stroke: none,
  table.hline(stroke: 0.8pt),
  [*Command*], [*Syntax Example*], [*Primary Function / Description*],
  table.hline(stroke: 0.4pt),
  [`uname`], [`uname -a`], [Print system kernel architecture, node name, and OS release.],
  [`clear`], [`clear`], [Clear the terminal screen buffer.],
  [`man`], [`man <command>`], [Format and display the on-line manual page for utilities, in more detail than "--help".],
  [`ps`], [`ps -aux`], [Report a snapshot of current active system processes. '-a' is for all with tty, except session leaders.],
  [`top`], [`top -n 1`], [Display dynamic real-time view of system process CPU/RAM usage. Though more aesthetic options are htop and btop],
  table.hline(stroke: 0.8pt)
)

== 2.3 Terminal Output
```bash
$ uname -a
Linux archlinux 7.1.3-arch2-1 #1 SMP PREEMPT_DYNAMIC Tue, 14 Jul 2026 23:03:30 +0000 x86_64 GNU/Linux

$ man ls | head -n 8
LS(1)                            User Commands                            LS(1)

NAME
       ls - list directory contents

SYNOPSIS
       ls [OPTION]... [FILE]...

$ ps -aux | head -n 5
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.3  19984 14428 ?        Ss   15:56   0:02 /sbin/init
root           2  0.0  0.0      0     0 ?        S    15:56   0:00 [kthreadd]
root           3  0.0  0.0      0     0 ?        S    15:56   0:00 [pool_workqueue_release]
root           4  0.0  0.0      0     0 ?        I<   15:56   0:00 [kworker/R-rcu_gp]

$ top -n 1 | head -n 7
top - 18:04:06 up  2:07,  1 user,  load average: 0.08, 0.11, 0.16
Tasks: 164 total, 1 running, 163 sleep, 0 d-sleep, 0 stopped, 0 zombie
%Cpu(s):  1.1 us,  2.2 sy,  0.0 ni, 96.7 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st 
MiB Mem :   3760.1 total,   1965.0 free,    728.0 used,   1450.0 buff/cache     
MiB Swap:   1880.0 total,   1866.4 free,     13.6 used.   3032.1 avail Mem 

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
```

#v(0.5em)

// =========================================================================
// PART C: NETWORK DIAGNOSTICS & CONFIGURATION
// =========================================================================
= 3. Experiment 1C: Network Diagnostics & Socket Inspection

== 3.1 Aim & Objective
To analyze loopback network interface reachability (`ping`), inspect interface address configurations (`ifconfig`), and list listening network sockets (`netstat`).

== 3.2 Command Summary & Syntax Analysis
#table(
  columns: (1.2fr, 1.5fr, 3fr),
  align: (left + horizon, left + horizon, left + horizon),
  stroke: none,
  table.hline(stroke: 0.8pt),
  [*Command*], [*Syntax Example*], [*Primary Function / Description*],
  table.hline(stroke: 0.4pt),
  [`ping`], [`ping -c 3 127.0.0.1`], [Send ICMP ECHO_REQUEST packets to network hosts. The '-c' option takes the number of ECHO_REQUEST packets to send as argument.],
  [`ifconfig`], [`ifconfig lo`], [Configure or display kernel network interface parameters. An alternative to this package is "ip".],
  [`ip`],[`ip address`],[Modern alternative to replace ifconfig. Show / manipulate routing, network devices, interfaces and tunnels],
  [`netstat`], [`netstat -tuln`], [Print network connections, routing tables, and interface stats.],
  [`ss`],[`ss`],[Modern alternative to netstat. Used to control sockets, and can show more info than netstat.],
  table.hline(stroke: 0.8pt)
)

== 3.3  Terminal Output
```bash
$ ping -c 3 127.0.0.1
PING 127.0.0.1 (127.0.0.1) 56(84) bytes of data.
64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.031 ms
64 bytes from 127.0.0.1: icmp_seq=2 ttl=64 time=0.038 ms
64 bytes from 127.0.0.1: icmp_seq=3 ttl=64 time=0.035 ms

--- 127.0.0.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2048ms
rtt min/avg/max/mdev = 0.031/0.034/0.038/0.003 ms

$ ifconfig lo
lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        rx packets 512  bytes 41200 (41.2 KB)
        tx packets 512  bytes 41200 (41.2 KB)

$ ip address
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: enp1s0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc fq_codel state DOWN group default qlen 1000
    link/ether fc:45:96:8c:03:ec brd ff:ff:ff:ff:ff:ff
    altname enxfc45968c03ec
3: wlp2s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 3c:f8:62:08:6a:15 brd ff:ff:ff:ff:ff:ff
    altname wlx3cf862086a15
    inet 10.179.123.29/24 brd 10.179.123.255 scope global dynamic noprefixroute wlp2s0
       valid_lft 2726sec preferred_lft 2726sec
    inet6 2401:4900:8387:1f47:9384:38cc:5a3:2094/64 scope global dynamic noprefixroute 
       valid_lft 6425sec preferred_lft 6425sec
    inet6 fe80::ca3f:8859:b07:4496/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
      
$ netstat -tuln | head -n 5
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State      
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN     
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN

$ ss -a | head
Netid State  Recv-Q Send-Q              Local Address:Port                    Peer Address:Port
nl    UNCONN 0      0                   rtnl:NetworkManager/441                         *
nl    UNCONN 0      0                   rtnl:xdg-desktop-por/715                        *
nl    UNCONN 0      0                   rtnl:-2115655789                                *
nl    UNCONN 0      0                   rtnl:kernel                                     *
nl    UNCONN 0      0                   rtnl:wpa_supplicant/489                         *
nl    UNCONN 0      0                   rtnl:firefox/8294                               *
nl    UNCONN 0      0                   rtnl:firefox/8294                               *
nl    UNCONN 0      0                   rtnl:xdg-desktop-por/715                        *
nl    UNCONN 0      0                   rtnl:-2115655789                                * 
```


