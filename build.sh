#!/bin/bash

set -e

DEPLOY_REPO="https://${GH_TOKEN}@github.com/gemoc/gemoc.github.io.git"

function main {
	clean
	get_current_site
	get_discovery_pages
	build_site
    deploy
}

function clean {
	echo "cleaning _site folder"
	if [ -d "_site" ]; then rm -Rf _site; fi
}

function get_current_site {
	echo "getting latest site"
	git clone --depth 1 $DEPLOY_REPO _site
}

function get_discovery_pages {
	echo "getting discovery pages"
	wget -P discovery https://raw.githubusercontent.com/gemoc/gemoc-studio/master/gemoc_studio/discovery/catalog.md
}

function build_site {
	echo "building site"
	bundle exec jekyll build
}

function deploy {
	echo "deploying changes"

     if [ -z "$TRAVIS_PULL_REQUEST" ]; then
         echo "except don't publish site for pull requests"
         exit 0
     fi

     if [ "$TRAVIS_BRANCH" != "gh-pages-edit" ]; then
         echo "except we should only publish the gh-page-edit branch. stopping here"
         exit 0
     fi


	cd _site
	git config --global user.name "Travis CI"
    git config --global user.email manuel.leduc@inria.fr
	git add -A
	git status
	git commit -m "Lastest site built on successful travis build $TRAVIS_BUILD_NUMBER auto-pushed to github"
	git push -f $DEPLOY_REPO HEAD:master
}


main
