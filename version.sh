#!/bin/bash

version_tag(){
  set -e
  tag=$(git describe --tags --first-parent --match "release/*" 2>/dev/null)
  exit_code=$?

  [[ $exit_code -ne "0" ]] && echo "git tag: 'release/*' missing" || echo $tag
}

current_release(){
  set -e
  version=$(version_tag)
  echo "$version" | cut -d'/' -f 2
}

major_version(){
  set -e
  current=$(current_release)
  echo "$current" | cut -d'.' -f 1
}

minor_version(){
  set -e
  current=$(current_release)
  echo "$current" | cut -d'.' -f 2
}

patch_version(){
  set -e
  current=$(current_release)
  echo "$current" | cut -d'.' -f 3
}

pretty_log(){
  git log --date='unix' --pretty=format:'%h%Creset -%d%Creset (%ai) <%an>%Creset %s' --abbrev-commit | head | awk -F ':' '{print $1":"$2":"$3}'
}

commit_sha(){
  git rev-parse HEAD
}

commit_short_sha(){
  git rev-parse --short HEAD
}

commit_author(){
  git log -1 --pretty=format:'%an'
}

commit_author_email(){
  git log -1 --pretty=format:'%ae'
}

commit_message(){
  git log -1 --pretty=format:'%B'
}

current_branch(){
  git rev-parse --abbrev-ref HEAD
}

release_version(){
  set -e
  version=$1

  git checkout -b "release/$version" origin/master &&\
    git tag "release/$version" &&\
    git push --set-upstream origin "release/$version" --tags
    # git push origin release/$version --tags
}

change_version(){
  set -e
  current_ver=$1
  new_version=$2

  git tag "version/end/$current_ver" &&\
    git commit --allow-empty -m"Incrementing version number to $new_version" &&\
    git tag "version/start/$new_version" &&\
    git push --tags origin "$(current_branch)"
}

increase_major_version(){
  set -e
  git reset --hard HEAD &&
  git pull --rebase &&\

  current_ver="$(current_release)" &&\
  new_version="$(next_major_version)" &&\

  change_version "$current_ver" "$new_version"
}

increase_minor_version(){
  set -e
  git reset --hard HEAD &&
  git pull --rebase &&\

  current_ver="$(current_release)" &&\
  new_version="$(next_minor_version)" &&\

  change_version "$current_ver" "$new_version"
}

increase_patch_version(){
  set -e
  if [[ "$(current_branch)" =  release/* ]]
  then
    git reset --hard HEAD &&\
    git pull --rebase &&\

    current_ver="$(current_release)" &&\
    new_version="$(next_patch_version)" &&\

    change_version "$current_ver" "$new_version"
  else
    echo This is not a release branch >&2
  fi
}

jenkins_version(){
  set -e
  if [[ "$(current_branch)" = release/* ]]
  then
    app_version
    elif [[ "$(current_branch)" = develop ]]
  then
    echo "develop-snapshot"
    elif [[ "$(current_branch)" = master ]]
  then
      app_version
  else
    sname=$(current_branch | awk -F '-' '{print $1"-"$2}')
    echo "${sname}-snapshot"
  fi
}

list_of_functions=$(grep -v "grep" "$0" | grep "()" | cut -d '(' -f 1)

help()
{
  printf "%s\n\n%s\n" "Usage: Provide any of the following sub_commands:" "$list_of_functions"
}

echo "$list_of_functions" | grep -w "$1" -q

exit_code=$?

# if [ $# -eq 0 ]
#   then
#     echo "No arguments supplied"
# fi

if [ $exit_code -ne "0" ]
then
  help
  exit 1
else
  "$1" "$2" "$3"
fi

# Update for 1.3.0
