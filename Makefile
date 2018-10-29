
#  "                    ___           ___           ___   "
#  "     _____         /\  \         /\  \         /\  \  "
#  "    /::\  \       /::\  \       /::\  \       /::\  \ "
#  "   /:/\:\  \     /:/\:\__\     /:/\:\  \     /:/\:\__\ "
#  "  /:/  \:\__\   /:/ /:/  /    /:/  \:\  \   /:/ /:/  / "
#  " /:/__/ \:|__| /:/_/:/__/___ /:/__/ \:\__\ /:/_/:/  /  "
#  " \:\  \ /:/  / \:\/:::::/  / \:\  \ /:/  / \:\/:/  /   "
#  "  \:\  /:/  /   \::/~~/~~~~   \:\  /:/  /   \::/__/    "
#  "   \:\/:/  /     \:\~~\        \:\/:/  /     \:\  \    "
#  "    \::/  /       \:\__\        \::/  /       \:\__\   "
#  "     \/__/         \/__/         \/__/         \/__/   "
#  " "
#  " "


PREFIX="drop-plgn-"
VERSION="0.1.0"

empty :=
space := $(empty) $(empty)
tab := $(empty)	$(empty)
comma := ,

define newline


endef

define comma_list
$(subst $(space),$(comma),$(strip $(1)))
endef


help:
	@printf '%s\n' ""\
		"Project $(MAKE) tool v${VERSION}" \
		"" \
		"Usage: make [target]..." \
		"" \
		"Core targets:" \
		"  init in=NAME     Create project structure with module NAME " \
		"  add-mod in=NAME  Add new NAME module" \
		"  run              Run module in shell mode (exec. ./test/cmd.d[0])" \
		"  docs             Build the documentation for this project (write to README)" \
		"  tests            Run the tests for this project" \
		"  bench c=C w=W    Run the tests & bench for this project" \
		"  clean            Delete temporary and output files from most targets" \
		"  help             Display this help and exit" \
		"" \
		"" 

init: add-mod
	$(eval n := $(in))              
	$(call render_template,tpl_before_install,./conf-scripts/before-install)
	$(call render_template,tpl_after_install,./conf-scripts/after-install)
	$(call render_template,tpl_cmd,./test/cmd.d)
	$(call render_template,tpl_input,./test/input.d)
	$(call render_template,tpl_output,./test/output.d)
	$(call render_template,tpl_test_run,./test/run)
	$(call render_template,tpl_config,./drop-plgn-$(in).json.example)


	@echo "rm -f /var/lib/drop/plugins/$(n)" >>./conf-scripts/before-install
	@echo "ln -s /opt/drop-plgn-$(n)/$(n)/$(n) /var/lib/drop/plugins/$(n)" >>./conf-scripts/after-install

	@printf '%s\n' ""\
		"Project created.."

struct:
	@mkdir -p ./conf-scripts
	@touch ./conf-scripts/before-install
	@chmod a+x ./conf-scripts/before-install
	@touch ./conf-scripts/after-install
	@chmod a+x ./conf-scripts/after-install
	@mkdir -p ./test
	@touch ./test/cmd.d
	@touch ./test/input.d
	@touch ./test/output.d
	@touch ./test/run
	@chmod a+x ./test/run


add-mod: struct
ifndef in                                                                       
	$(error Usage: $(MAKE) init in=NAME)                                      
endif
	$(eval p := $(in))                                                          
	@mkdir -p ./$p
	@touch ./$p/$p
	@chmod a+x ./$p/$p
	@echo "rm -f /var/lib/drop/plugins/$(p)" >>./conf-scripts/before-install
	@echo "ln -s /opt/drop-plgn-$(p)/$(p)/$(p) /var/lib/drop/plugins/$(p)" >>./conf-scripts/after-install
	@printf '%s\n' ""\
		"Module $p created.."

run:
	head -n 3 ./test/cmd.d |tail -1|sh

tests:
	@cd ./test && ./run && cd ../

bench:
	@cd ./test && ./run $(c) $(w) && cd ../

clean:
	@find . ! -name 'Makefile' -type f -exec rm -rf {} +
	@find . ! -name 'Makefile' -type d -exec rm -rf {} +

docs:
	@echo "# API description #" >README.md
	@cat ./test/cmd.d >>README.md
	@echo " " >>README.md
	@cat ./test/input.d >>README.md
	@echo " " >>README.md
	@cat ./test/output.d >>README.md


define render_template
	@printf -- '$(subst $(newline),\n,$(subst %,%%,$(subst ','\'',$(subst $(tab),$(WS),$(call $(1))))))\n' > $(2)
endef

## TEMPLATES

define tpl_before_install
#!/bin/sh
# Don't change this file
# Its generate automatically

rm -f /var/lib/drop/flows/drop-plgn-$(n).json
endef


define tpl_after_install
#!/bin/sh
# Don't change this file
# Its generate automatically

## create symlink
ln -s /opt/drop-plgn-$(n)/drop-plgn-$(n).json /var/lib/drop/flows/drop-plgn-$(n).json
endef

define tpl_cmd
## plugin start cmds

cmd1

cmd2

...

endef


define tpl_input
## input data msg 

### write msg1

test msg

### write msg2

test msg2

...

endef


define tpl_output
## output data msg

ok

ok

...

endef

define tpl_config

 NAME - flow name (ex. drop-plgn-example)
 PPOOL_NAME - name of function (global register in cluster)
 CMD - cmd to exec
 TIMEOUT - cmd exec timeout
 FILTER - topic subcribtion/ part of msg or tag
 SUB_SRATEGY - one - sync one to one
               sone - stream one one
			   done - distribued one to one, if local nomore
			   all - all subs on host
			   dall - all in cluster

 

 {
    "name": "NAME",  
    "active": 0,
    "priority": 0,
    "version": 0,
    "entry_ppool": "PPOOL_NAME",
    "start_scene": "start",
    "scenes":[
        {
            "name" : "start",
            "cook": [
                {"num":1,
                 "cmd":"system::local::start_pool::PPOOL_NAME::1"
                },
				...

                {"num":3,
                 "cmd":"system::local::start_all_workers::PPOOL_NAME::CMD -plugin PPOOL_NAME ::PPOOL_NAME.log::TIMEOUT"
                },
				...
                {"num":5,
                 "cmd":"system::local::subscribe::PPOOL_NAME::PPOOL_NAME::FILTER::SUB_SRATEGY"
                }
				...
 
            ]

        },
        {
            "name" : "stop",
            "cook": [
                {"num":1,
                 "cmd":"system::local::stop_pool::PPOOL_NAME"
                },
				...

            ]

        }
		...
    ]

}


endef


define tpl_test_run
#!/usr/bin/python
#
# test runner
#

import subprocess as sp
import os
import time
import sys


def run_shell(d, cmd):
    with open(os.devnull, 'w') as devnull:
        return sp.check_output("echo '{}'|{} 2>/dev/null ;exit 0".
                               format(d, cmd), stderr=devnull, shell=True)


def test(cmd):

    print("start testing cmd {}\\n".format(cmd))
    in0 = [x for x in open("./input.d").read().split("\\n\\n") if not x.startswith("##")]
    out = [x for x in open("./output.d").read().split("\\n\\n") if not x.startswith("##")]

    _i = "\\n".join([x.replace("\\n", "\tncm\t") for x in in0])

    _d = run_shell(_i, cmd).split("\\n")

    for r, o, i0 in zip(_d, out, in0):
        _r = r.replace("\tncm\t", "\\n")
        if _r != o:
            print("TEST FAILED!!!\\n in: {}\\n out: {}\\n expected: {}\\n".format(i0, _r, o))


def bench(cmd, b, w):

    if b is None:
        return

    print("start bench cmd {}\\n".format(cmd))
    in0 = [x for x in open("./input.d").read().split("\\n\\n") if not x.startswith("##")]

    for b1 in in0:

        _i = "{}\\n".format(b1.replace("\\n", "\tncm\t"))*(b+1)

        tb = time.time()
        _d = run_shell(_i[0], cmd).split("\\n")
        start_up_proc = time.time() - tb

        tb = time.time()
        _d = run_shell(_i, cmd).split("\\n")
        te = time.time() - tb - start_up_proc

        if te > w:
            print("...count:{} \\n in: {}\\n time: {}\\n water mark {}\\n".
                  format(len(_d), b1, te, w))


def main(b, w):
    _cmds = open("./cmd.d").read().split("\\n\\n")
    [test(x) for x in _cmds if not x.startswith("##") and x!=""]
    [bench(x, b, w) for x in _cmds if not x.startswith("##") and x!=""]


if __name__ == "__main__":
    try:
        _bench_c, _bench_wm = int(sys.argv[1]), float(sys.argv[2])
    except:
        _bench_c, _bench_wm = None, None

    main(_bench_c, _bench_wm)
endef


