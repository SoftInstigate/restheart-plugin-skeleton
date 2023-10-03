#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
repo_dir="${script_dir}"/..
cache_dir="${repo_dir}"/.cache
rh_dir="${cache_dir}"/restheart
http_port=8080

usage() {
  cat << EOF # remove the space between << and EOF, this is due to web plugin issue
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-b] [-w] [-i [-v version]] [-p http_port] [-o restheart options] [--no-color] [command]

Helper script to Build, Watch and Deploy the plugin, automatically restarting RESTHeart. It also installs RESTHeart.

Commands:

b, build   Build and deploy the plugin, restarting RESTHeart (default)
r, run     start (or restarts) RESTHeart
k, kill    Kill RESTHeart
w, watch   Watch sources and build and deploy the plugin on changes, restarting RESTHeart

Available options:

-h, --help          Print this help and exit
-i, --install       Force reinstalling RESTHeart
-v, --version       RESTHeart version tag to install (default is latest)
-p, --port          HTTP port to use (default is 8080)
-o, --options       pass options to RESTHeart
--no-color          Disable colored output

Examples:

${BASH_SOURCE[0]} build                                 build the plugin, deploy it and run RESTHeart with it
${BASH_SOURCE[0]}                                       like 'build'
${BASH_SOURCE[0]} start                                 start or restart RESTHeart
${BASH_SOURCE[0]} watch                                 automatically re-run on code changes
${BASH_SOURCE[0]} --port 9090 -o "-s"                   run on HTTP port 9090 with standalone configuration (-s)
${BASH_SOURCE[0]} -o "-c"                               print RESTHeart effective configuration
${BASH_SOURCE[0]} -i -v 7.1.0 run                       Force reinstalling RESHeart version 7.1.0, then run
RHO='/logging/log-level->"debug"' ${BASH_SOURCE[0]}     run passing the RHO env var to override configuration


All commands automatically download and install RESTHeart if needed.

EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

command_exists () {
    type "$1" &> /dev/null ;
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "${RED}$msg${NOFORMAT}"
  exit "$code"
}

parse_params() {
  # default values of variables set from params
  force_install_flag=0
  command='build'
  run_flag=0
  no_watch_flag=0
  version='latest'
  options=""
  params=$*

  while :; do
    case "${1-}" in
    k | kill)
      command='kill'
      ;;
    r | run)
      command='run'
      ;;
    b | build)
      command='build'
      ;;
    w | watch)
      command='watch'
      ;;
    -h | --help) usage ;;
    -v | --version)
      version="${2-}"
      shift
      ;;
    --no-color) NO_COLOR=1 ;;
    --no-watch)
      no_watch_flag=1
      ;;
    -i | --install) force_install_flag=1 ;;
    -o | --options)
      options="${2-}"
      if [[ -z ${options}  ]] ; then
        msg "${RED}Error: missing value of --options"
        exit 1
      fi
      shift
      ;;
    --port)
      http_port="${2-}"
      shift
      if ! [[ ${http_port} =~ ^[0-9]+$ ]] ; then
        msg "${RED}Error: The value of --port must be number, got ${http_port}${NOFORMAT}"
        exit 1
      fi
      ;;
    -?*) die "Unknown option: $1" ;;
    ?*) die "Unknown command: $1" ;;
    *) break ;;
    esac
    shift
  done

  return 0
}

_install() {
    if [ ${force_install_flag}"x" = "1x" ]
    then
        msg "${CYAN}Cleaning cache${NOFORMAT}"
        rm -rf "${cache_dir}"
    fi

    if [ ! -d "${rh_dir}"  ]
    then
        msg "${GREEN}Installing RESTHeart version ${version} ${NOFORMAT}"

        if [ ! -d "${cache_dir}"  ]; then mkdir "${cache_dir}"; fi

        if _download; then
            msg "${GREEN}RESTHeart version ${version} downloaded${NOFORMAT}"
        else
            die "${RED}Failed to download RESTHeart version ${version}${NOFORMAT}"
        fi

        tar -xzf "${cache_dir}"/restheart.tar.gz -C "${cache_dir}"
        rm -f "${cache_dir}"/restheart.tar.gz
    fi

    return 0
}

_download() {
    case "${version}" in
        latest)
            curl --fail -L https://github.com/SoftInstigate/restheart/releases/latest/download/restheart.tar.gz --output "${cache_dir}"/restheart.tar.gz 2>/dev/null
            curl_res=$?
            ;;
        *)
            curl --fail -L https://github.com/SoftInstigate/restheart/releases/download/${version}/restheart.tar.gz --output "${cache_dir}"/restheart.tar.gz 2>/dev/null
            curl_res=$?
            ;;
    esac

    return ${curl_res}
}

_mongodb_running() {
    if ! curl -s -o /dev/null localhost:27017; then
        msg "${RED}It looks like mongodb is not running on port 27017.${NOFORMAT}"
        msg "You can start it with:"
        msg "> docker compose up -d"
        exit 1
    fi

    return 0
}

_restheart_running() {
    if curl -s -o /dev/null localhost:${http_port}/ping; then
        return 0
    else
        return 1
    fi
}

# check if RESTHeart options specify the standalone option -s
_requires_mongondb() {
    if [[ ${options} =~ .*-s.* ]]; then
        return 0
    else
        return 1
    fi
}

# check if RESTHeart only prints the configuration
_only_print_conf() {
    if [[ ${options} =~ .*-t.*|.*-c.*|.*-v.* ]]; then
        return 0
    else
        return 1
    fi
}

_build() {
    rm -rf "${repo_dir}"/target

    currd=`pwd`

    cd "${repo_dir}"

    if __build; then
        cd ${currd}
        return 0
    else
        cd ${currd}
        die "Failed to build RESTHeart"
    fi
}

__build() {
    ./mvnw -f "${repo_dir}"/pom.xml clean package
    return $?
}

_deploy() {
    cp "${repo_dir}"/target/*.jar "${rh_dir}"/plugins
    cp "${repo_dir}"/target/lib/*.jar "${rh_dir}"/plugins

    msg "${GREEN}Plugin deployed${NOFORMAT}"

    return 0
}

_kill() {
    msg "${CYAN}RESTHeart at localhost:${http_port} killed${NOFORMAT}"
    kill `comm -12 <(lsof -t -i:${http_port}) <(pgrep java)` 2> /dev/null || echo .. > /dev/null
    kill `comm -12 <(lsof -t -i:$((http_port+1000))) <(pgrep java)` 2> /dev/null || echo .. > /dev/null

    # give some time JDWP process to exit
    sleep 2

    while _restheart_running; do sleep 1; done

    return 0
}

_run() {
    if [ -z ${RHO:-""} ]; then
        if _only_print_conf; then
            RHO="/http-listner/port->${http_port};" java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=0.0.0.0:$((http_port+1000)) -jar "${rh_dir}"/restheart.jar ${options}
        else
            RHO="/http-listner/port->${http_port};" nohup java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=0.0.0.0:$((http_port+1000)) -jar "${rh_dir}"/restheart.jar ${options} > "${repo_dir}"/restheart.log &
            msg "${YELLOW}RESTHeart starting${NOFORMAT}"
            started=0
            for i in {1..5}; do
                if _restheart_running; then
                    started=1
                    break
                else
                    sleep 1
                fi
            done
            if (( ${started}  == 1 )); then
                msg "${GREEN}RESTHeart started at localhost:${http_port}${NOFORMAT}"
                msg "${CYAN}JDWP available for debuggers at localhost:$((http_port+1000))${NOFORMAT}"
            else
                msg "${RED}Error starting RESTHeart, check restheart.log${NOFORMAT}"
            fi
        fi
    else
        if _only_print_conf; then
            RHO=\"${RHO}";/http-listener/port->${http_port}\"" java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=0.0.0.0:$((http_port+1000)) -jar "${rh_dir}"/restheart.jar ${options}
        else
            RHO=\"${RHO}";/http-listener/port->${http_port}\"" nohup java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=0.0.0.0:$((http_port+1000)) -jar "${rh_dir}"/restheart.jar ${options} > "${repo_dir}"/restheart.log &
            msg "${YELLOW}RESTHeart starting${NOFORMAT}"
            started=0
            for i in {1..5}; do
                if _restheart_running; then
                    started=1
                    break
                else
                    sleep 1
                fi
            done
            if (( ${started}  == 1 )); then
                msg "${GREEN}RESTHeart started at localhost:${http_port}${NOFORMAT}"
                msg "${CYAN}JDWP available for debuggers at localhost:$((http_port+1000))${NOFORMAT}"
            else
                msg "${RED}Error starting RESTHeart, check restheart.log${NOFORMAT}"
            fi
        fi
    fi

    return 0
}

_watch() {
    # check that command entr is available
    if ! command_exists entr ; then
        msg "${RED}Error: --watch requires entr${NOFORMAT}"
        msg " OSX:    ${YELLOW}brew install entr${NOFORMAT}"
        msg " Debian: ${YELLOW}sudo apt-get install -y entr${NOFORMAT}"
        msg " More info at https://github.com/eradman/entr"
        exit 1
    fi

    find "${repo_dir}" \( -path "${repo_dir}/src/*" -and -name "*.java" \) | entr sh -c "${repo_dir}/bin/$(basename "${BASH_SOURCE[0]}") run ${params} --no-watch"

    msg "${GREEN}RESTHeart started at localhost:${http_port}${NOFORMAT}"
    msg "${CYAN}JDWP available for debuggers at localhost:$((http_port+1000))${NOFORMAT}"

    return 0
}

setup_colors
parse_params "$@"

case "${command}" in
    run)
        if _restheart_running; then _kill; fi
        _install
        if  _requires_mongondb; then _mongodb_running; fi
        _run
        ;;
    build)
        if _restheart_running; then _kill; fi
        _install
        _build
        _deploy
        if _requires_mongondb; then _mongodb_running; fi
        _run
        ;;
    watch)
        if [ ${no_watch_flag}"x" = "1x" ]; then
            if _restheart_running; then _kill; fi
            _install
            _build
            _deploy
            if _requires_mongondb; then _mongodb_running; fi
            _run
        else
            _watch
        fi
        ;;
    kill)
        if _restheart_running; then _kill; else msg "${CYAN}RESTHeart is not running on port ${http_port}${NOFORMAT}"; fi
        exit 0
        ;;
    *)
        die "Unknown command: ${command}"
        ;;
esac
