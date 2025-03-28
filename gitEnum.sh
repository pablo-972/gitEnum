#!/bin/bash

YELLOW="\033[33m"
RESET="\033[0m"
GREEN="\033[32m"

# Header
header() {
    echo "---------------------------------------------"
    echo "        _ _   ______                        "
    echo "       (_) | |  ____|                       "
    echo "   __ _ _| |_| |__   _ __  _   _ _ __ ___  "
    echo "  / _\` | | __|  __| | '_ \| | | | '_  _ \ "
    echo " | (_| | | |_| |____| | | | |_| | | | | | |"
    echo "  \__, |_|\__|______|_| |_|\__,_|_| |_| |_|"
    echo "   __/ |                                    "
    echo "  |___/                                     "
    echo -e "\n---------------------------------------------"
    echo -e "By Sulkaz\n"
}


# Usage
usage(){
    header 
    echo -e "Usage: $0 [-h] [-l] [-c] [-r] [-p] \n"
    echo "Options:"
    echo "-h    <help>"
    echo "-l   <commit hashes list>"
    echo "-h   <commit hash>"
    echo "-r   <route list>"
    echo "-p   <path of .git directory if not in>"
}


# Functions
git_routes(){
    hash=$1
    path=$2
    git -C "$path" show "$hash" | grep "+++" | awk '{print substr($0, 6)}' | grep "^/" | sed 's/^\/\(.*\)/\1/' > routes.txt
}

git_show(){
    route=$1
    path=$2
    echo -e "${YELLOW}------------------- [+] Getting $route resource...${RESET}\n"
    git -C "$path" show ":$route" 2>/dev/null 
    echo -e "\n${YELLOW}----------------------------------------------------------------------------${RESET}\n\n\n"
}


# At least a parameter
if [ $# -eq 0 ]; then
    usage
fi

# Variables
commit_hashes_list=""
commit_hash=""
route_list=""
path_git=""

#Show header
header

# Parameters
while getopts ":h:l:r:c:p:" opt; do
    case $opt in
        h)  usage ;;
        l) commit_hashes_list=$OPTARG ;;
        c) commit_hash=$OPTARG ;;
        r) route_list=$OPTARG ;;
        p) path_git=$OPTARG ;;
        ?) usage ;;
    esac
done

# Check parameters
if [ -z "$path_git" ]; then
    path_git="."
fi

# 1. commit_hashes_list
if [ ! -z "$commit_hashes_list" ]; then
    if [ ! -f "$commit_hashes_list" ]; then
        echo "Error: the file '$commit_hashes_list' doesn't exist"
        exit 1
    fi

    if [ ! -s "$commit_hashes_list" ]; then
        echo "Error: the file '$commit_hashes_list' is empty"
        exit 1
    fi

    while IFS= read -r hash; do
        git_routes "$hash" "$path_git"
        if [ ! -s "routes.txt" ]; then
            echo "Error: No valid routes found in routes.txt"
            exit 1
        fi
        while IFS= read -r route; do
            git_show "$route" "$path_git"
        done < "routes.txt"
    done < "$commit_hashes_list"
fi

# 2. commit_hash
if [ ! -z "$commit_hash" ]; then
    git_routes "$commit_hash" "$path_git"
    if [ ! -s "routes.txt" ]; then
        echo "Error: No valid routes found in routes.txt"
        exit 1
    fi
    while IFS= read -r route; do
        git_show "$route" "$path_git"
    done < "routes.txt"
fi

# 3. route_list
if [ ! -z "$route_list" ]; then
    while IFS= read -r route; do
        git_show "$route" "$path_git"
    done < "$route_list"
fi