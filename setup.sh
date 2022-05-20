#!/bin/sh
scope ()
(
    # ---------- VARIABLES -----------

    script_path="$(dirname "$(readlink -e -- "$0")")"
    script_name="$(basename "$0")"
    logfile_name=/dev/null
    runtime_dependencies="sudo awk fc-cache"
    export SUDO_ASKPASS="$(which ssh-askpass)"
    unset verbose
    unset distname

    # https://stackoverflow.com/a/39959192
    distname="$(awk -F'=' '/^ID=/ {print tolower($2)}' /etc/*-release)"

    sourcedir="$script_path"

    if [  "$distname" == "fedora" ]
    then
	installlocation="/usr/share/fonts/atolisglli"
    elif [ "$distname" == "ubuntu" ]
    then
	installlocation="/usr/share/fonts/atolisglli"
    fi

    # font files --- Use single quotes because double ones would be
    # prematurely expanded by the subshell
    averia=$(find $sourcedir/averia -type f -iname '*ttf' -o -type f -iname '*otf')
    fantasque=$(find $sourcedir/fantasque_sans -type f -iname '*ttf' -o -type f -iname '*otf')
    firacode=$(find $sourcedir/fira_code/Fira_Code_v5.2/ttf/ -type f -iname '*ttf' -o -type f -iname '*otf')
    hack=$(find $sourcedir/hack -type f -iname '*ttf' -o -type f -iname '*otf')
    hasklig=$(find $sourcedir/hasklig -type f -iname '*ttf' -o -type f -iname '*otf')
    ia_writer=$(find $sourcedir/ia_writer -type f -iname '*ttf' -o -type f -iname '*otf')
    input=$(find $sourcedir/input -type f -iname '*ttf' -o -type f -iname '*otf')
    monoid=$(find $sourcedir/monoid -type f -iname '*ttf' -o -type f -iname '*otf')
    noto=$(find $sourcedir/noto -type f -iname '*ttf' -o -type f -iname '*otf')
    opendyslexic=$(find $sourcedir/opendyslexic -type f -iname '*ttf' -o -type f -iname '*otf')
    pokemon_pixels=$(find $sourcedir/pokemon_pixels -type f -iname '*ttf' -o -type f -iname '*otf')
    roboto=$(find $sourcedir/roboto -type f -iname '*ttf' -o -type f -iname '*otf')
    unifont=$(find $sourcedir/unifont -type f -iname '*ttf' -o -type f -iname '*otf')
    # which to install
    ins="$averia $fantasque $firacode $hack $hasklig $ia_writer $input $monoid $noto $opendyslexic $roboto $unifont"

    # ---------- ARGPARSE ------------

    while getopts 'lv' c
    do
	case $c in
	    l) logfile_name="log_${script_name%.*}.txt"; shift ;;
	    v) verbose=1; shift ;;
	    --) shift; break ;;
	    *) echo "[ERROR] unsupported argument: $1"; usage ;;
	esac
    done

    # ---------- FUNCTIONS -----------

    usage () {
	printf "%b\n" "Usage: $script_name [-v] [-l]"
	exit 2
    }
    hello () {
	printf "%b\n" "[INFO] $script_path/$script_name\n$(date -Iseconds)"
	printf "%b\n" "Install custom fonts"
    }
    log () {
	if [ -n "$verbose" ]
	then
	    "$@" | tee -a $logfile_name
	else
	    "$@" >> $logfile_name
	fi
    }
    debug () {
	if [ -n "$debug" ]
	then
	    "$@"
	fi
    }
    check_for_app () {
	for dep in $@
	do
	    if [ -n "$(which $dep)" ]
	    then
		printf "%b\n" "found $dep"
	    else
		printf "%b\n" "[ERROR] $dep not found, aborting"
		exit 2
	    fi
	done
    }
    trysudo () {
	if [ -n "$(getent group sudo | grep -o $USER)" ]
	then
	    if [ -n "$SUDO_ASKPASS" ]
	    then
		sudo -A "$@"
	    else
		read -s -t 30 -p "[sudo] password for $USER: " sudoPW
		echo $sudoPW | sudo -S "$@"
		unset sudoPW
	    fi
	else
	    printf "%b\n" "[WARN] $USER has no sudo rights: $@"
	fi
    }

    # ---------- MAIN ----------------

    main () {
	hello
	check_for_app $runtime_dependencies

	printf "%b\n" "[INFO] create directory $installlocation"
	sudo mkdir -p "$installlocation"

	printf "%b\n" "[INFO] copy font files"

	for font in "$ins"
	do
	    # don't put " around $font here, since it contains many
	    # file references
	    debug echo $font
	    sudo cp -v $font "$installlocation"
	done

	printf "%b\n" "[INFO] rebuild font cache"
	sudo fc-cache -f -v

	printf "%b\n" ""
    }
    log main $@
)
scope $@

# ---------- COMMENTS ------------
