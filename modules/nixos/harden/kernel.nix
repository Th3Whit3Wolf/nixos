{ config, options, lib, ... }:

let
    cfg = config.harden.kernel;
in {
    options = {
        harden.kernel =  {
            enable = lib.mkEnableOption "Enable some low-hanging fruit kernel hardenening.";
        };
    };
    config = lib.mkIf (cfg.enable) {
        boot = {
            kernelModules = [ "tcp_bbr" ];
            kernelParams = [
                # Slab/slub sanity checks, redzoning, and poisoning
                "slub_debug=FZP"

                # Overwrite free'd memory
                "page_poison=1"

                # Enable page allocator randomization
                "page_alloc.shuffle=1"
            ];
            kernel.sysctl = {
                # Restrict ptrace() usage to processes with a pre-defined relationship
                # (e.g., parent/child)
                "kernel.yama.ptrace_scope" = 1;

                # Hide kptrs even for processes with CAP_SYSLOG
                "kernel.kptr_restrict" = 2;

                # Disable bpf() JIT (to eliminate spray attacks)
                "net.core.bpf_jit_enable" = false;

                # Disable ftrace debugging
                "kernel.ftrace_enabled" = false;

                # Enable strict reverse path filtering (that is, do not attempt to route
                # packets that "obviously" do not belong to the iface's network; dropped
                # packets are logged as martians).
                "net.ipv4.conf.all.log_martians" = true;
                "net.ipv4.conf.all.rp_filter" = "1";
                "net.ipv4.conf.default.log_martians" = true;
                "net.ipv4.conf.default.rp_filter" = "1";

                # The Magic SysRq key is a key combo that allows users connected to the
                # system console of a Linux kernel to perform some low-level commands.
                # Disable it, since we don't need it, and is a potential security concern.
                "kernel.sysrq" = 0;

                # * TCP hardening
                # Prevent bogus ICMP errors from filling up logs.
                "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
                # Do not accept IP source route packets (we're not a router)
                "net.ipv4.conf.all.accept_source_route" = 0;
                "net.ipv6.conf.all.accept_source_route" = 0;
                # Ignore outgoing ICMP redirects (this is ipv4 only)
                "net.ipv4.conf.all.send_redirects" = 0;
                "net.ipv4.conf.default.send_redirects" = 0;
                # Ignore incoming ICMP redirects (note: default is needed to ensure that the
                # setting is applied to interfaces added after the sysctls are set)

                "net.ipv4.conf.all.accept_redirects" = 0;
                "net.ipv4.conf.default.accept_redirects" = 0;
                "net.ipv4.conf.all.secure_redirects" = 0;
                "net.ipv4.conf.default.secure_redirects" = 0;
                "net.ipv6.conf.all.accept_redirects" = 0;
                "net.ipv6.conf.default.accept_redirects" = 0;
                # Protects against SYN flood attacks
                "net.ipv4.tcp_syncookies" = 1;
                # Incomplete protection again TIME-WAIT assassination
                "net.ipv4.tcp_rfc1337" = 1;

                ## TCP optimization
                # TCP Fast Open is a TCP extension that reduces network latency by packing
                # data in the sender’s initial TCP SYN. Setting 3 = enable TCP Fast Open for
                # both incoming and outgoing connections:
                "net.ipv4.tcp_fastopen" = 3;
                # Bufferbloat mitigations + slight improvement in throughput & latency
                "net.ipv4.tcp_congestion_control" = "bbr";
                #"net.core.default_qdisc" = "cake";

            } // lib.optionalAttrs (true) {
                # Refuse ICMP echo requests on desktop/laptop; nobody has any business
                # pinging them, unlike a servers.
                "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
                "net.ipv6.icmp_echo_ignore_broadcasts" = 1;
            };
        };
    };
}
