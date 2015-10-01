#!/usr/bin/env sh


# ----------------------------------------------------------------------

# loader.sh
#
# This is a generic/universal implementation of Shell Script Loader
# that targets all shells based from sh.
#
# Please see loader.txt for more info on how to use this script.
#
# This script complies with the Requiring Specifications of
# Shell Script Loader version 0 (RS0).
#
# Version: 0.1.1
#
# Author: konsolebox
# Copyright Free / Public Domain
# Aug. 29, 2009 (Last Updated 2011/07/14)

# Note:
#
# Some shells or some shell versions may not not have the full
# capability of supporting Shell Script Loader.  For example, some
# earlier versions of Zsh (earlier than 4.2) have limitations to the
# number of levels or recursions that its functions and/or commands that
# can be actively executed.

# ----------------------------------------------------------------------


#### PUBLIC VARIABLES ####

LOADER_VERSION=0.1.1
LOADER_RS=0
LOADER_ACTIVE=true


#### PUBLIC FUNCTIONS ####

load() {
	[ "$#" -eq 0 ] && loader_fail "function called with no argument." load

	case "$1" in
	'')
		loader_fail "file expression cannot be null." load "$@"
		;;
	/*|./*|../*)
		if [ -f "$1" ]; then
			loader_getabspath "$1"

			[ -r "$__" ] || loader_fail "file not readable: $__" load "$@"

			shift
			loader_load "$@"

			return
		fi
		;;
	*)
		if loader_findfile "$1"; then
			[ -r "$__" ] || loader_fail "found file not readable: $__" load "$@"

			loader_flag_ "$1"

			shift
			loader_load "$@"

			return
		fi
		;;
	esac

	loader_fail "file not found: $1" load "$@"
}

include() {
	[ "$#" -eq 0 ] && loader_fail "function called with no argument." include

	case "$1" in
	'')
		loader_fail "file expression cannot be null." include "$@"
		;;
	/*|./*|../*)
		loader_getabspath "$1"

		loader_flagged "$__" && \
			return

		if [ -f "$__" ]; then
			[ -r "$__" ] || loader_fail "file not readable: $__" include "$@"

			shift
			loader_load "$@"

			return
		fi
		;;
	*)
		loader_flagged "$1" && \
			return

		loader_include_loop "$@" && \
			return
		;;
	esac

	loader_fail "file not found: $1" include "$@"
}

call() {
	[ "$#" -eq 0 ] && loader_fail "function called with no argument." call

	case "$1" in
	'')
		loader_fail "file expression cannot be null." call "$@"
		;;
	/*|./*|../*)
		if [ -f "$1" ]; then
			loader_getabspath "$1"

			[ -r "$__" ] || loader_fail "file not readable: $__" call "$@"

			(
				shift
				loader_load "$@"
			)

			return
		fi
		;;
	*)
		if loader_findfile "$1"; then
			[ -r "$__" ] || loader_fail "found file not readable: $__" call "$@"

			(
				loader_flag_ "$1"

				shift
				loader_load "$@"
			)

			return
		fi
		;;
	esac

	loader_fail "file not found: $1" call "$@"
}

loader_addpath() {
	for __
	do
		[ -d "$__" ] || loader_fail "directory not found: $__" loader_addpath "$@"
		[ -x "$__" ] || loader_fail "directory not accessible: $__" loader_addpath "$@"
		[ -r "$__" ] || loader_fail "directory not searchable: $__" loader_addpath "$@"
		loader_getabspath "$__/."
		loader_addpath_ "$__"
	done
	loader_updatefunctions
}

loader_flag() {
	[ "$#" -eq 1 ] || loader_fail "function requires a single argument." loader_flag "$@"
	loader_getabspath "$1"
	loader_flag_ "$__"
}

loader_reset() {
	if [ "$#" -eq 0 ]; then
		loader_resetflags
		loader_resetpaths
	elif [ "$1" = flags ]; then
		loader_resetflags
	elif [ "$1" = paths ]; then
		loader_resetpaths
	else
		loader_fail "invalid argument: $1" loader_reset "$@"
	fi
}

loader_finish() {
	LOADER_ACTIVE=false

	loader_unsetvars
	loader_unsetfunctions

	unset \
		load \
		include \
		call \
		loader_addpath \
		loader_addpath_ \
		loader_fail \
		loader_findfile \
		loader_finish \
		loader_flag \
		loader_flag_ \
		loader_flagged \
		loader_getabspath \
		loader_include_loop \
		loader_load \
		loader_reset \
		loader_resetflags \
		loader_resetpaths \
		loader_unsetfunctions \
		loader_unsetvars \
		loader_updatefunctions
}


#### PRIVATE VARIABLES AND SHELL-DEPENDENT FUNCTIONS ####

LOADER_ADVANCED=false

if [ -n "$BASH_VERSION" ]; then
	if ( case "$BASH" in sh|*/sh) exit 1;; esac; exit 0; ) && [ "$BASH_VERSION" '>' 2.03 ]; then
		eval '
			LOADER_CS=()
			LOADER_CS_I=0
			LOADER_PATHS=()

			if [[ BASH_VERSINFO -ge 5 || (BASH_VERSINFO -eq 4 && BASH_VERSINFO[1] -ge 2) ]]; then
				declare -g -A LOADER_FLAGS=()
				declare -g -A LOADER_PATHS_FLAGS=()
				LOADER_USEAARRAYS=true
			elif [[ BASH_VERSINFO -eq 4 ]] && declare -A LOADER_TEST1 &>/dev/null && ! local LOADER_TEST2 &>/dev/null; then
				declare -A LOADER_FLAGS=()
				declare -A LOADER_PATHS_FLAGS=()
				LOADER_USEAARRAYS=true
			else
				LOADER_USEAARRAYS=false
			fi
		'

		if [[ $LOADER_USEAARRAYS = true ]]; then
			eval '
				function loader_addpath_ {
					if [[ -z ${LOADER_PATHS_FLAGS[$1]} ]]; then
						LOADER_PATHS[${#LOADER_PATHS[@]}]=$1
						LOADER_PATHS_FLAGS[$1]=.
					fi
				}

				loader_flag_() {
					LOADER_FLAGS[$1]=.
				}

				function loader_flagged {
					[[ -n ${LOADER_FLAGS[$1]} ]]
				}

				function loader_resetflags {
					LOADER_FLAGS=()
				}

				function loader_resetpaths {
					LOADER_PATHS=()
					LOADER_PATHS_FLAGS=()
				}

				function loader_unsetvars {
					unset LOADER_CS LOADER_CS_I LOADER_FLAGS LOADER_PATHS LOADER_PATHS_FLAGS
				}
			'
		else
			eval '
				function loader_addpath_ {
					for __ in "${LOADER_PATHS[@]}"; do
						[[ $1 = "$__" ]] && \
							return
					done

					LOADER_PATHS[${#LOADER_PATHS[@]}]=$1
				}

				loader_flag_() {
					local V
					V=${1//./_dt_}
					V=${V// /_sp_}
					V=${V//\//_sl_}
					V=LOADER_FLAGS_${V//[^[:alnum:]_]/_ot_}
					eval "$V=."
				}

				function loader_flagged {
					local V
					V=${1//./_dt_}
					V=${V// /_sp_}
					V=${V//\//_sl_}
					V=LOADER_FLAGS_${V//[^[:alnum:]_]/_ot_}
					[[ -n ${!V} ]]
				}

				function loader_resetflags {
					local IFS=\ ;
					unset ${!LOADER_FLAGS_*}
				}

				function loader_resetpaths {
					LOADER_PATHS=()
				}

				function loader_unsetvars {
					local IFS=\ ;
					unset LOADER_CS LOADER_CS_I LOADER_PATHS ${!LOADER_FLAGS_*}
				}
			'
		fi

		unset LOADER_USEAARRAYS

		if [[ BASH_VERSINFO -ge 3 ]]; then
			eval "
				function loader_getabspath_ {
					local -a T1 T2
					local -i I=0
					local IFS=/ A

					case \"\$1\" in
					/*)
						read -r -a T1 <<< \"\$1\"
						;;
					*)
						read -r -a T1 <<< \"/\$PWD/\$1\"
						;;
					esac

					T2=()

					for A in \"\${T1[@]}\"; do
						case \"\$A\" in
						..)
							[[ I -ne 0 ]] && unset T2\\[--I\\]
							continue
							;;
						.|'')
							continue
							;;
						esac

						T2[I++]=\$A
					done

					case \"\$1\" in
					*/)
						[[ I -ne 0 ]] && __=\"/\${T2[*]}/\" || __=/
						;;
					*)
						[[ I -ne 0 ]] && __=\"/\${T2[*]}\" || __=/.
						;;
					esac
				}
			"
		elif [[ $BASH_VERSION = 2.05b ]]; then
			eval "
				function loader_getabspath_ {
					local -a T=()
					local -i I=0
					local IFS=/ A

					case \"\$1\" in
					/*)
						__=\$1
						;;
					*)
						__=/\$PWD/\$1
						;;
					esac

					while read -r -d / A; do
						case \"\$A\" in
						..)
							[[ I -ne 0 ]] && unset T\\[--I\\]
							continue
							;;
						.|'')
							continue
							;;
						esac

						T[I++]=\$A
					done <<< \"\$__/\"

					case \"\$1\" in
					*/)
						[[ I -ne 0 ]] && __=\"/\${T[*]}/\" || __=/
						;;
					*)
						[[ I -ne 0 ]] && __=\"/\${T[*]}\" || __=/.
						;;
					esac
				}
			"
		else
			eval "
				function loader_getabspath_ {
					local -a T=()
					local -i I=0
					local IFS=/ A

					case \"\$1\" in
					/*)
						__=\$1
						;;
					*)
						__=/\$PWD/\$1
						;;
					esac

					while read -r -d / A; do
						case \"\$A\" in
						..)
							[[ I -ne 0 ]] && unset T\\[--I\\]
							continue
							;;
						.|'')
							continue
							;;
						esac

						T[I++]=\$A
					done << .
\$__/
.

					case \"\$1\" in
					*/)
						[[ I -ne 0 ]] && __=\"/\${T[*]}/\" || __=/
						;;
					*)
						[[ I -ne 0 ]] && __=\"/\${T[*]}\" || __=/.
						;;
					esac
				}
			"
		fi

		LOADER_ADVANCED=true
	fi
elif [ -n "$ZSH_VERSION" ]; then
	if
		eval '[ "${ZSH_VERSION%%.*}" -ge 4 ]' && \
		[ ! "$ZSH_NAME" = sh -a ! "$ZSH_NAME" = ksh ]
	then
		eval "
			typeset -g -a LOADER_CS
			typeset -g -i LOADER_CS_I=0
			typeset -g -A LOADER_FLAGS
			typeset -g -a LOADER_PATHS
			typeset -g -A LOADER_PATHS_FLAGS

			function loader_addpath_ {
				if [[ -z \${LOADER_PATHS_FLAGS[\$1]} ]]; then
					LOADER_PATHS[\${#LOADER_PATHS[@]}+1]=\$1
					LOADER_PATHS_FLAGS[\$1]=.
				fi
			}

			loader_flag_() {
				LOADER_FLAGS[\$1]=.
			}

			function loader_flagged {
				[[ -n \${LOADER_FLAGS[\$1]} ]]
			}

			function loader_getabspath_ {
				local -a TOKENS; set -A TOKENS
				local -i I=0
				local IFS=/ T

				__=\$1

				case \"\$1\" in
				/*)
					set -- \${=1}
					;;
				*)
					set -- \${=PWD} \${=1}
					;;
				esac

				for T; do
					case \"\$T\" in
					..)
						[[ I -ne 0 ]] && TOKENS[I--]=()
						continue
						;;
					.|'')
						continue
						;;
					esac

					TOKENS[++I]=\$T
				done

				case \"\$__\" in
				*/)
					[[ I -ne 0 ]] && __=\"/\${TOKENS[*]}/\" || __=/
					;;
				*)
					[[ I -ne 0 ]] && __=\"/\${TOKENS[*]}\" || __=/.
					;;
				esac
			}

			function loader_resetflags {
				set -A LOADER_FLAGS
			}

			function loader_resetpaths {
				set -A LOADER_PATHS
				set -A LOADER_PATHS_FLAGS
			}

			function loader_unsetvars {
				unset LOADER_CS LOADER_CS_I LOADER_FLAGS LOADER_PATHS LOADER_PATHS_FLAGS
			}
		"

		LOADER_ADVANCED=true
	fi
elif [ -n "$KSH_VERSION" ]; then
	eval "
		set -A LOADER_CS
		LOADER_CS_I=0
		set -A LOADER_PATHS

		loader_addpath_() {
			for __ in \"\${LOADER_PATHS[@]}\"; do
				[[ \$1 = \"\$__\" ]] && \\
					return
			done

			LOADER_PATHS[\${#LOADER_PATHS[@]}]=\$1
		}

		loader_flag_() {
			eval \"LOADER_FLAGS_\$(echo \"\$1\" | sed \"s/\\./_dt_/g; s/\\//_sl_/g; s/ /_sp_/g; s/[^[:alnum:]_]/_ot_/g\")=.\"
		}

		loader_flagged() {
			eval \"[[ -n \\\$LOADER_FLAGS_\$(echo \"\$1\" | sed \"s/\\./_dt_/g; s/\\//_sl_/g; s/ /_sp_/g; s/[^[:alnum:]_]/_ot_/g\") ]]\"
		}

		loader_getabspath_() {
			typeset A T IFS=/ TOKENS I=0 J=0

			A=\${1%/}

			if [[ -n \$A ]]; then
				while :; do
					T=\${A%%/*}

					case \"\$T\" in
					..)
						if [[ I -gt 0 ]]; then
							unset TOKENS\\[--I\\]
						else
							(( ++J ))
						fi
						;;
					.|'')
						;;
					*)
						TOKENS[I++]=\$T
						;;
					esac

					case \"\$A\" in
					*/*)
						A=\${A#*/}
						;;
					*)
						break
						;;
					esac
				done
			fi

			__=\"/\${TOKENS[*]}\"

			if [[ \$1 != /* ]]; then
				A=\${PWD%/}

				while [[ J -gt 0 && -n \$A ]]; do
					A=\${A%/*}
					(( --J ))
				done

				[[ -n \$A ]] && __=\$A\${__%/}
			fi

			if [[ \$__ = / ]]; then
				[[ \$1 != */ ]] && __=/.
			elif [[ \$1 == */ ]]; then
				__=\$__/
			fi
		}

		loader_resetflags() {
			unset \$(set | grep -a ^LOADER_FLAGS_ | cut -f 1 -d =)
		}

		loader_resetpaths() {
			set -A LOADER_PATHS
		}

		loader_unsetvars() {
			unset LOADER_CS LOADER_CS_I LOADER_PATHS
			loader_resetflags
		}
	"

	LOADER_ADVANCED=true
elif
	( eval '[ -n "${.sh.version}" ] && exit 10'; ) >/dev/null 2>&1
	[ "$?" -eq 10 ]
then
	eval "
		set -A LOADER_CS_I
		LOADER_CS_I=0
		LOADER_FLAGS=([.]=.)
		set -A LOADER_PATHS
		LOADER_PATHS_FLAGS=([.]=.)

		loader_addpath_() {
			if [[ -z \${LOADER_PATHS_FLAGS[\$1]} ]]; then
				LOADER_PATHS[\${#LOADER_PATHS[@]}]=\$1
				LOADER_PATHS_FLAGS[\$1]=.
			fi
		}

		loader_flag_() {
			LOADER_FLAGS[\$1]=.
		}

		loader_flagged() {
			[[ -n \${LOADER_FLAGS[\$1]} ]]
		}

		loader_resetflags() {
			LOADER_FLAGS=()
		}

		loader_resetpaths() {
			set -A LOADER_PATHS
			LOADER_PATHS_FLAGS=()
		}

		loader_unsetvars() {
			unset LOADER_CS LOADER_CS_I LOADER_FLAGS LOADER_PATHS LOADER_PATHS_FLAGS
		}
	"

	if
		eval "
			__=.
			read __ <<< \"\$__\"
			[[ \$__ = '\".\"' ]]
		"
	then
		eval "
			function loader_getabspath_ {
				typeset T1 T2
				typeset -i I=0
				typeset IFS=/ A

				case \"\$1\" in
				/*)
					read -r -A T1 <<< \$1
					;;
				*)
					read -r -A T1 <<< \$PWD/\$1
					;;
				esac

				set -A T2

				for A in \"\${T1[@]}\"; do
					case \"\$A\" in
					..)
						[[ I -ne 0 ]] && unset T2\\[--I\\]
						continue
						;;
					.|'')
						continue
						;;
					esac

					T2[I++]=\$A
				done

				case \"\$1\" in
				*/)
					[[ I -ne 0 ]] && __=\"/\${T2[*]}/\" || __=/
					;;
				*)
					[[ I -ne 0 ]] && __=\"/\${T2[*]}\" || __=/.
					;;
				esac
			}
		"
	else
		eval "
			function loader_getabspath_ {
				typeset T1 T2
				typeset -i I=0
				typeset IFS=/ A

				case \"\$1\" in
				/*)
					read -r -A T1 <<< \"\$1\"
					;;
				*)
					read -r -A T1 <<< \"\$PWD/\$1\"
					;;
				esac

				set -A T2

				for A in \"\${T1[@]}\"; do
					case \"\$A\" in
					..)
						[[ I -ne 0 ]] && unset T2\\[--I\\]
						continue
						;;
					.|'')
						continue
						;;
					esac

					T2[I++]=\$A
				done

				case \"\$1\" in
				*/)
					[[ I -ne 0 ]] && __=\"/\${T2[*]}/\" || __=/
					;;
				*)
					[[ I -ne 0 ]] && __=\"/\${T2[*]}\" || __=/.
					;;
				esac
			}
		"
	fi

	LOADER_ADVANCED=true
fi

if [ "$LOADER_ADVANCED" = true ]; then
	eval "
		loader_fail() {
			typeset MESSAGE FUNC A I

			MESSAGE=\$1 FUNC=\$2
			shift 2

			{
				echo \"loader: \${FUNC}(): \${MESSAGE}\"
				echo

				echo \"  current scope:\"
				if [[ LOADER_CS_I -gt 0 ]]; then
					echo \"    \${LOADER_CS[LOADER_CS_I]}\"
				else
					echo \"    (main)\"
				fi
				echo

				if [[ \$# -gt 0 ]]; then
					echo \"  command:\"
					echo -n \"    \$FUNC\"
					for A in \"\$@\"; do
						echo -n \" \\\"\$A\\\"\"
					done
					echo
					echo
				fi

				if [[ LOADER_CS_I -gt 0 ]]; then
					echo \"  call stack:\"
					echo \"    (main)\"
					I=1
					while [[ I -le LOADER_CS_I ]]; do
						echo \"    -> \${LOADER_CS[I]}\"
						(( ++I ))
					done
					echo
				fi

				echo \"  search paths:\"
				if [[ \${#LOADER_PATHS[@]} -gt 0 ]]; then
					for A in \"\${LOADER_PATHS[@]}\"; do
						echo \"    \$A\"
					done
				else
					echo \"    (empty)\"
				fi
				echo

				echo \"  working directory:\"
				echo \"    \$PWD\"
				echo
			} >&2

			exit 1
		}

		loader_findfile() {
			for __ in \"\${LOADER_PATHS[@]}\"; do
				if [ -f \"\$__/\$1\" ]; then
					loader_getabspath \"\$__/\$1\"
					return 0
				fi
			done
			return 1
		}

		loader_getabspath() {
			case \"\$1\" in
			.|'')
				case \"\$PWD\" in
				/)
					__=/.
					;;
				*)
					__=\${PWD%/}
					;;
				esac
				;;
			..|../*|*/..|*/../*|./*|*/.|*/./*|*//*)
				loader_getabspath_ \"\$1\"
				;;
			/*)
				__=\$1
				;;
			*)
				__=\${PWD%/}/\$1
				;;
			esac
		}

		loader_include_loop() {
			for __ in \"\${LOADER_PATHS[@]}\"; do
				loader_getabspath \"\$__/\$1\"

				if loader_flagged \"\$__\"; then
					loader_flag_ \"\$1\"

					return 0
				elif [[ -f \$__ ]]; then
					[ -r \"$__\" ] || loader_fail \"found file not readable: \$__\" loader_include_loop \"\$@\"

					loader_flag_ \"\$1\"

					shift
					loader_load \"\$@\"

					return 0
				fi
			done

			return 1
		}

		loader_load() {
			loader_flag_ \"\$__\"

			LOADER_CS[++LOADER_CS_I]=\$__

			loader_load_ \"\$@\"

			__=\$?

			LOADER_CS[LOADER_CS_I--]=

			return \"\$__\"
		}

		loader_load_() {
			. \"\$__\"
		}

		loader_unsetfunctions() {
			unset loader_load_ loader_getabspath_
		}

		loader_updatefunctions() {
			:
		}
	"
else
	eval "
		LOADER_FLAGS=''
		LOADER_PATHS=''
		LOADER_SCOPE='(main)'
		LOADER_V=''

		loader_addpath_() {
			LOADER_V=\$1

			if [ -n \"\$LOADER_PATHS\" ]; then
				eval \"set -- \$LOADER_PATHS\"

				for __
				do
					[ \"\$__\" = \"\$LOADER_V\" ] && return
				done
			fi

			case \"\$LOADER_V\" in
			*[\\\\\\\"]*)
				loader_fail \"can't support directory names with characters '\\\\' and '\\\"'.\" loader_addpath_ \"\$@\"
				;;
			*\\\$*)
				LOADER_V=\`echo \"\$LOADER_V\" | sed 's/\\\$/\\\\\\\$/g'\`
				;;
			esac

			LOADER_PATHS=\$LOADER_PATHS' \"'\$LOADER_V'\"'
		}

		loader_fail() {
			MESSAGE=\$1 FUNC=\$2
			shift 2

			{
				echo \"loader: \${FUNC}(): \${MESSAGE}\"
				echo

				echo \"  current scope:\"
				echo \"    \$LOADER_SCOPE\"
				echo

				if [ \"\$#\" -gt 0 ]; then
					echo \"  command:\"
					__=\"    \$FUNC\"
					for A in \"\$@\"; do
						__=\$__\" \\\"\$A\\\"\"
					done
					echo \"\$__\"
					echo
				fi

				echo \"  search paths:\"
				if [ -n \"\$LOADER_PATHS\" ]; then
					eval \"set -- \$LOADER_PATHS\"
					for A in \"\$@\"; do
						echo \"    \$A\"
					done
				else
					echo \"    (empty)\"
				fi
				echo

				echo \"  working directory:\"
				loader_getcwd
				echo \"    \$__\"
				echo
			} >&2

			exit 1
		}

		loader_findfile() {
			return 1
		}

		if
			(
				eval '
					__=\"ABCabc. /*?\" && \\
					__=\${__//./_dt_} && \\
					__=\${__// /_sp_} && \\
					__=\${__//\\//_sl_} && \\
					__=\${__//[^A-Za-z0-9_]/_ot_} && \\
					[ \"\$__\" = \"ABCabc_dt__sp__sl__ot__ot_\" ] && \\
					exit 10
				'
			) >/dev/null 2>&1
			[ \"\$?\" -eq 10 ]
		then
			eval '
				loader_flag_() {
					LOADER_V=\${1//./_dt_}
					LOADER_V=\${LOADER_V// /_sp_}
					LOADER_V=\${LOADER_V//\\//_sl_}
					LOADER_V=LOADER_FLAGS_\${LOADER_V//[^A-Za-z0-9_]/_ot_}
					eval \"\$LOADER_V=.\"
					LOADER_FLAGS=\$LOADER_FLAGS\\ \$LOADER_V
				}

				loader_flagged() {
					LOADER_V=\${1//./_dt_}
					LOADER_V=\${LOADER_V// /_sp_}
					LOADER_V=\${LOADER_V//\\//_sl_}
					LOADER_V=LOADER_FLAGS_\${LOADER_V//[^A-Za-z0-9_]/_ot_}
					eval \"[ -n \\\"\\\$\$LOADER_V\\\" ]\"
				}
			'
		else
			loader_flag_() {
				LOADER_V=LOADER_FLAGS_\`echo \"\$1\" | sed 's/\\./_dt_/g; s/ /_sp_/g; s/\\//_sl_/g; s/[^[:alnum:]_]/_ot_/g'\`
				eval \"\$LOADER_V=.\"
				LOADER_FLAGS=\$LOADER_FLAGS\\ \$LOADER_V
			}

			loader_flagged() {
				LOADER_V=LOADER_FLAGS_\`echo \"\$1\" | sed 's/\\./_dt_/g; s/ /_sp_/g; s/\\//_sl_/g; s/[^[:alnum:]_]/_ot_/g'\`
				eval \"[ -n \\\"\\\$\$LOADER_V\\\" ]\"
			}
		fi

		loader_getabspath() {
			case \"\$1\" in
			.|'')
				loader_getcwd

				case \"\$__\" in
				/)
					__=/.
					;;
				*)
					__=\$__
					;;
				esac
				;;
			..|../*|*/..|*/../*|./*|*/.|*/./*|*//*)
				loader_getabspath_ \"\$1\"
				;;
			/*)
				__=\$1
				;;
			*)
				loader_getcwd

				case \"\$__\" in
				/)
					__=/\$1
					;;
				*)
					__=\$__/\$1
					;;
				esac
				;;
			esac
		}

		loader_getabspath_() {
			case \"\$1\" in
			/*)
				__=\$1
				;;
			*)
				loader_getcwd
				__=\$__/\$1
				;;
			esac

			__=\`loader_getabspath__\`

			case \"\$1\" in
			*/)
				[ ! \"$__\" = / ] && __=\$__/
				;;
			*)
				[ \"\$__\" = / ] && __=/.
				;;
			esac
		}

		loader_getabspath__() {
			set -f
			IFS=/
			set -- \$__

			while :; do
				__='' L=''

				for A
				do
					shift

					case \"\$A\" in
					..)
						[ -z \"\$L\" ] && continue
						shift \"\$#\"
						set -- \$__ \"\$@\"
						continue 2
						;;
					.|'')
						continue
						;;
					esac

					[ -n \"\$L\" ] && __=\$__/\$L
					L=\$A
				done

				__=\$__/\$L

				break
			done

			echo \"\$__\"
		}

		if
			(
				cd /bin || cd /usr/bin || cd /usr/local/bin || exit 1
				__=\$PWD
				cd /lib || cd /usr/lib || cd /usr/local/lib || exit 1
				[ ! \"\$__\" = \"\$PWD\" ]
				exit \"\$?\"
			) >/dev/null 2>&1
		then
			loader_getcwd() {
				__=\$PWD
			}
		else
			loader_getcwd() {
				__=\`exec pwd\`
			}
		fi

		if
			(
				set -f || exit 1
				loader_getabspath_ '/.././a/b/c/../d'
				[ \"\$__\" = '/a/b/d' ] || exit 1
				PREFIX=''
				loader_getcwd
				[ ! \"\$__\" = / ] && PREFIX=\$__
				loader_getabspath_ '/./..//*/a/b/../c /../d 0/1/2/3/4/5/6/7/8/9'
				[ \"\$__\" = \"/*/a/d 0/1/2/3/4/5/6/7/8/9\" ] || exit 1
				loader_getabspath_ './*/a/b/../c /../d 0'
				[ \"\$__\" = \"\$PREFIX/*/a/d 0\" ] && exit 10
			) >/dev/null 2>&1
			[ \"\$?\" -ne 10 ]
		then
			unset loader_getabspath_ loader_getabspath__

			if
				( [ \"\`exec getabspath /a/../.\`\" = /. ] && exit 10; ) >/dev/null 2>&1
				[ \"\$?\" -eq 10 ]
			then
				loader_getabspath_() {
					__=\`exec getabspath \"\$1\"\`
				}
			else
				loader_getabspath_() {
					loader_getcwd

					__=\`
						exec awk -- '
							BEGIN {
								PATH = ARGV[1]

								if (ARGV[1] !~ \"^[/]\")
									PATH = ARGV[2] \"/\" PATH

								FS = \"/\"
								\$0 = PATH

								T = 0

								for (F = 1; F <= NF; F++) {
									if (\$F == \".\" || \$F == \"\") {
										continue
									} else if (\$F == \"..\") {
										if (T)
											--T
									} else {
										TOKENS[T++]=\$F
									}
								}

								if (T) {
									for (I = 0; I < T; I++)
										ABS = ABS \"/\" TOKENS[I]
									if (PATH ~ /\\/\$/)
										ABS = ABS \"/\"
								} else if (PATH ~ /\\/\$/) {
									ABS = \"/\"
								} else {
									ABS = \"/.\"
								}

								print ABS

								exit
							}
						' \"\$1\" \"\$__\"
					\`
				}
			fi
		fi

		loader_include_loop() {
			return 1
		}

		loader_load() {
			loader_flag_ \"\$__\"

			set -- \"\$LOADER_SCOPE\" \"\$@\"
			LOADER_SCOPE=\$__

			loader_load_ \"\$@\"

			__=\$?
			[ -n \"\$LOADER_SCOPE\" ] && LOADER_SCOPE=\$1
			return \"\$__\"
		}

		loader_load_() {
			shift
			. \"\$__\"
		}

		loader_resetflags() {
			eval \"unset __ \$LOADER_FLAGS\"
			LOADER_FLAGS=''
		}

		loader_resetpaths() {
			LOADER_PATHS=''
			loader_updatefunctions

		}

		loader_unsetvars() {
			loader_resetflags
			unset LOADER_FLAGS LOADER_PATHS LOADER_SCOPE LOADER_V
		}

		loader_unsetfunctions() {
			unset loader_getabspath_ loader_getcwd loader_load_
		}

		loader_updatefunctions() {
			if [ -n \"\$LOADER_PATHS\" ]; then
				eval \"
					loader_findfile() {
						for __ in \$LOADER_PATHS; do
							if [ -f \\\"\\\$__/\\\$1\\\" ]; then
								loader_getabspath \\\"\\\$__/\\\$1\\\"
								return 0
							fi
						done
						return 1
					}

					loader_include_loop() {
						for __ in \$LOADER_PATHS; do
							loader_getabspath \\\"\\\$__/\\\$1\\\"

							if loader_flagged \\\"\\\$__\\\"; then
								loader_flag_ \\\"\\\$1\\\"

								return 0
							elif [ -f \\\"\\\$__\\\" ]; then
								[ -r \\\"\$__\\\" ] || loader_fail \\\"found file not readable: \\\$__\\\" loader_include_loop \\\"\\\$@\\\"

								loader_flag_ \\\"\\\$1\\\"

								shift
								loader_load \\\"\\\$@\\\"

								return 0
							fi
						done

						return 1
					}
				\"
			else
				loader_findfile() { return 1; }
				loader_include_loop() { return 1; }
			fi
		}
	"
fi

unset LOADER_ADVANCED


# ----------------------------------------------------------------------

# * In loader_getabspath_() of ordinary shells, we require 'set -f' to
#   prevent glob characters from being parsed.  We have to place it
#   inside a subshell to make it not affect the current environment.
#   We also place the statements inside another function in an attempt
#   to make it not re-parse every command every time the subshell runs.
#   Zsh may also require 'setopt shwordsplit' but we don't have to do it
#   there since it already has its own function.

# * heirloom-sh 050706 doesn't recognize ; as a delimeter when [in ...]
#   argument is not mentioned in for loop. i.e. 'for VAR; do ...; done'
#   causes syntax error.  Also, when value of IFS is different, "$@"
#   doesn't expand to multiple arguments.

# * When no argument is passed to 'set --', it doesn't do anything.

# * Some shells can only contain 9 active positional parameters.

# ----------------------------------------------------------------------
